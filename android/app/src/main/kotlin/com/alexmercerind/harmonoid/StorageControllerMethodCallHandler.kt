package com.alexmercerind.harmonoid

import android.app.Activity
import android.app.RecoverableSecurityException
import android.content.ContentUris
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.RequiresApi
import io.flutter.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.io.File
import java.io.FileOutputStream
import kotlin.io.path.Path

class StorageControllerMethodCallHandler(private val activity: Activity, private val channel: MethodChannel) : MethodChannel.MethodCallHandler {
    companion object {
        private const val GET_STORAGE_DIRECTORIES_METHOD_NAME = "getStorageDirectories"
        private const val GET_CACHE_DIRECTORY_METHOD_NAME = "getCacheDirectory"
        private const val GET_DEFAULT_MEDIA_LIBRARY_DIRECTORY_METHOD_NAME = "getDefaultMediaLibraryDirectory";
        private const val GET_VERSION_METHOD_NAME = "getVersion"
        private const val DELETE_METHOD_NAME = "delete"
        /* private */ const val NOTIFY_DELETE_METHOD_NAME = "notifyDelete"
        const val GET_COVER_FILE_METHOD_NAME = "getCoverFile"

        private const val DELETE_ARG_PATHS = "paths"
        private const val GET_COVER_FILE_ARG_PATH = "path"

        /* private */ const val DELETE_REQUEST_CODE = 1
    }

    private val scope = CoroutineScope(Dispatchers.IO)
    private val mutex = Mutex()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            GET_STORAGE_DIRECTORIES_METHOD_NAME -> {
                val value = activity.storageDirectories
                Log.d(TAG, value.toString())
                result.success(value)
            }

            GET_CACHE_DIRECTORY_METHOD_NAME -> {
                val value = activity.cacheDirectory
                Log.d(TAG, value)
                result.success(value)
            }

            GET_DEFAULT_MEDIA_LIBRARY_DIRECTORY_METHOD_NAME -> {
                val value = activity.defaultMediaLibraryDirectory
                Log.d(TAG, value)
                result.success(value)
            }

            GET_VERSION_METHOD_NAME -> {
                val version: Int = Build.VERSION.SDK_INT
                Log.d(TAG, version.toString())
                result.success(version)
            }

            DELETE_METHOD_NAME -> {
                val paths = call.argument<List<String>>(DELETE_ARG_PATHS)
                if (!paths.isNullOrEmpty()) {
                    when {
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> deleteAPILevel30(paths)
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> deleteAPILevel29(paths)
                        else -> deleteAPILevel28(paths)
                    }
                }
                result.success(null)
            }

            GET_COVER_FILE_METHOD_NAME -> {
                scope.launch {
                    mutex.withLock {
                        runCatching {
                            val path = call.argument<String>(GET_COVER_FILE_ARG_PATH)!!
                            val contentUri = path.toCoverContentUri()!!
                            File(Path(activity.cacheDirectory, this@StorageControllerMethodCallHandler::class.java.name, path.md5).toString()).run {
                                if (length() == 0L) {
                                    parentFile?.run { mkdirs() }
                                    activity.contentResolver.openInputStream(contentUri).use { it?.copyTo(FileOutputStream(this)) }
                                }
                                Log.d(TAG, absolutePath)
                                result.success(absolutePath)
                            }
                        }.onFailure {
                            it.printStackTrace()
                            result.success(null)
                        }
                    }
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.R)
    private fun deleteAPILevel30(paths: List<String>) {
        if (tryAndDelete(paths)) {
            channel.invokeMethod(NOTIFY_DELETE_METHOD_NAME, true)
            return
        }

        runCatching {
            val pendingIntent = MediaStore.createDeleteRequest(activity.contentResolver, paths.map { path -> path.toContentUri()!! })
            activity.startIntentSenderForResult(pendingIntent.intentSender, DELETE_REQUEST_CODE, null, 0, 0, 0, null)
            // Refer MainActivity.onActivityResult for result handling.
        }.onFailure {
            it.printStackTrace()
            channel.invokeMethod(NOTIFY_DELETE_METHOD_NAME, false)
        }
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun deleteAPILevel29(paths: List<String>) {
        if (tryAndDelete(paths)) {
            channel.invokeMethod(NOTIFY_DELETE_METHOD_NAME, true)
            return
        }

        if (paths.size == 1) {
            try {
                val response = activity.contentResolver.delete(paths.first().toContentUri()!!, null, null)
                channel.invokeMethod(NOTIFY_DELETE_METHOD_NAME, response > 0)
            } catch (e: SecurityException) {
                e.printStackTrace()
                try {
                    val recoverableSecurityException = e as? RecoverableSecurityException
                    val intentSender = recoverableSecurityException?.userAction?.actionIntent?.intentSender
                    if (intentSender != null) {
                        activity.startIntentSenderForResult(
                            intentSender, DELETE_REQUEST_CODE, Intent(paths.first().toContentUri().toString()), 0, 0, 0, null
                        )
                        // Refer MainActivity.onActivityResult for result handling.
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                    channel.invokeMethod(NOTIFY_DELETE_METHOD_NAME, false)
                }
            } catch (e: Exception) {
                e.printStackTrace()
                channel.invokeMethod(NOTIFY_DELETE_METHOD_NAME, false)
            }
        } else {
            // API 29 can't delete multiple files at once.
            channel.invokeMethod(NOTIFY_DELETE_METHOD_NAME, false)
        }
    }

    private fun deleteAPILevel28(paths: List<String>) {
        val result = tryAndDelete(paths)
        channel.invokeMethod(NOTIFY_DELETE_METHOD_NAME, result)
    }

    private fun tryAndDelete(paths: List<String>): Boolean {
        for (path in paths) {
            val result = runCatching { File(path).deleteRecursively() }.getOrDefault(false)
            if (!result) {
                return false
            }
        }
        return true
    }

    private fun String.toContentUri(): Uri? {
        val value = this

        runCatching {
            val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            } else {
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            }
            val projection = arrayOf(MediaStore.Audio.Media._ID, MediaStore.Audio.Media.DATA)
            val selection = "${MediaStore.Audio.Media.DATA} = ?"
            val selectionArgs = arrayOf(value)
            val sortOrder = "${MediaStore.Audio.Media._ID} ASC"
            val query = activity.contentResolver.query(
                collection, projection, selection, selectionArgs, sortOrder
            )
            query?.use { cursor ->
                Log.d(TAG, "ContentResolver.query: cursor.count = ${cursor.count}")
                if (cursor.count > 0) {
                    cursor.moveToFirst()
                    val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
                    val dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
                    val id = cursor.getLong(idColumn)
                    val data = cursor.getString(dataColumn)
                    Log.d(TAG, "ContentResolver.query: id = $id")
                    Log.d(TAG, "ContentResolver.query: data = $data")
                    return ContentUris.withAppendedId(collection, id)
                }
            }
        }
        runCatching {
            val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            } else {
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI
            }
            val projection = arrayOf(MediaStore.Video.Media._ID, MediaStore.Video.Media.DATA)
            val selection = "${MediaStore.Video.Media.DATA} = ?"
            val selectionArgs = arrayOf(value)
            val sortOrder = "${MediaStore.Video.Media._ID} ASC"
            val query = activity.contentResolver.query(
                collection, projection, selection, selectionArgs, sortOrder
            )
            query?.use { cursor ->
                Log.d(TAG, "ContentResolver.query: cursor.count = ${cursor.count}")
                if (cursor.count > 0) {
                    cursor.moveToFirst()
                    val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
                    val dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
                    val id = cursor.getLong(idColumn)
                    val data = cursor.getString(dataColumn)
                    Log.d(TAG, "ContentResolver.query: id = $id")
                    Log.d(TAG, "ContentResolver.query: data = $data")
                    return ContentUris.withAppendedId(collection, id)
                }
            }
        }
        runCatching {
            val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            } else {
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            }
            val projection = arrayOf(MediaStore.Images.Media._ID, MediaStore.Images.Media.DATA)
            val selection = "${MediaStore.Images.Media.DATA} = ?"
            val selectionArgs = arrayOf(value)
            val sortOrder = "${MediaStore.Images.Media._ID} ASC"
            val query = activity.contentResolver.query(
                collection, projection, selection, selectionArgs, sortOrder
            )
            query?.use { cursor ->
                Log.d(TAG, "ContentResolver.query: cursor.count = ${cursor.count}")
                if (cursor.count > 0) {
                    cursor.moveToFirst()
                    val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
                    val dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
                    val id = cursor.getLong(idColumn)
                    val data = cursor.getString(dataColumn)
                    Log.d(TAG, "ContentResolver.query: id = $id")
                    Log.d(TAG, "ContentResolver.query: data = $data")
                    return ContentUris.withAppendedId(collection, id)
                }
            }
        }
        return null
    }

    private fun String.toCoverContentUri(): Uri? {
        val value = this

        runCatching {
            val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            } else {
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            }
            val projection = arrayOf(MediaStore.Audio.Media._ID, MediaStore.Audio.Media.DATA, MediaStore.Audio.Media.ALBUM_ID)
            val selection = "${MediaStore.Audio.Media.DATA} = ?"
            val selectionArgs = arrayOf(value)
            val sortOrder = "${MediaStore.Audio.Media._ID} ASC"
            val query = activity.contentResolver.query(
                collection, projection, selection, selectionArgs, sortOrder
            )
            query?.use { cursor ->
                Log.d(TAG, "ContentResolver.query: cursor.count = ${cursor.count}")
                if (cursor.count > 0) {
                    cursor.moveToFirst()
                    val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
                    val dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
                    val albumIdColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
                    val id = cursor.getLong(idColumn)
                    val data = cursor.getString(dataColumn)
                    val albumId = cursor.getLong(albumIdColumn)
                    Log.d(TAG, "ContentResolver.query: id = $id")
                    Log.d(TAG, "ContentResolver.query: data = $data")
                    Log.d(TAG, "ContentResolver.query: albumId = $albumId")
                    return ContentUris.withAppendedId(Uri.parse("content://media/external/audio/albumart"), albumId)
                }
            }
        }
        return null
    }
}
