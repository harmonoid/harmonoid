/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

package com.alexmercerind.harmonoid

import android.app.Activity
import android.app.RecoverableSecurityException
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.RequiresApi
import io.flutter.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

const val STORAGE_RETRIEVER_DELETE_REQUEST_CODE: Int = 0xAA
const val STORAGE_RETRIEVER_DELETE_NOTIFY_METHOD_NAME =
    "com.alexmercerind.StorageRetriever/delete"

// Gets the absolute paths for internal storage & external SD card.
// This is the only solution.
//
// By default, [getExternalFilesDirs] returns the application specific & private path e.g.
// `/storage/emulated/0/Android/data/com.alexmercerind.harmonoid/files`.
//
// This is because Android is promoting Scoped Storage & [MediaStore], which unfortunately
// fail many of our use cases like custom or multiple directory selection for music indexing
// or looking for .LRC files in the same directory as audio file etc.
// Since, Harmonoid's indexer & music library manager `package:media_library` (written in Dart) is
// completely file-system based, having raw access to file paths & file system is important.
// It is because Windows, Linux & Android share the same business logic.
//
// Currently passing reference to it's [MethodChannel] itself.
//
class StorageRetriever(private val channel: MethodChannel?, private val context: Context) :
    MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when {
            call.method.equals("volumes") -> {
                val volumes: List<String> = context.getExternalFilesDirs(null)
                    .map { file -> file.absolutePath.split("/Android/")[0] }
                Log.d("Harmonoid", volumes.toString())
                result.success(volumes)
            }
            call.method.equals("cache") -> {
                val cache: String? = context.getExternalFilesDirs(null).firstOrNull()?.absolutePath
                Log.d("Harmonoid", cache.toString())
                result.success(cache)
            }
            call.method.equals("version") -> {
                val version: Int = Build.VERSION.SDK_INT
                Log.d("Harmonoid", version.toString())
                result.success(version)
            }
            call.method.equals("delete") -> {
                val paths: List<String>? = call.argument<List<String>?>("paths")
                Log.d("Harmonoid", paths.toString())
                if (paths != null) {
                    when {
                        // Android 11 or higher allows to delete multiple external files but with proper permission from the user.
                        // I'm using [MediaStore.createDeleteRequest] for this.
                        // Hopefully, multiple files can be deleted unlike Android 10, where scoped storage was newly implemented.
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> {
                            try {
                                if (!File(paths.first()).deleteRecursively()) {
                                    deleteAPILevel30(paths)
                                } else {
                                    channel?.invokeMethod(
                                        STORAGE_RETRIEVER_DELETE_NOTIFY_METHOD_NAME, true
                                    )
                                }
                            } catch (e: Exception) {
                                e.printStackTrace()
                                deleteAPILevel30(paths)
                            }
                        }
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> {
                            try {
                                if (!File(paths.first()).deleteRecursively()) {
                                    deleteAPILevel29(paths)
                                } else {
                                    channel?.invokeMethod(
                                        STORAGE_RETRIEVER_DELETE_NOTIFY_METHOD_NAME, true
                                    )
                                }
                            } catch (e: Exception) {
                                e.printStackTrace()
                                deleteAPILevel29(paths)
                            }
                        }
                        // No permissions needed on Android Pie or lower.
                        // Use [java.io.File] directly. Good old days!
                        else -> {
                            for (path in paths) {
                                try {
                                    File(path).deleteRecursively()
                                } catch (e: Exception) {
                                    e.printStackTrace()
                                }
                            }
                            channel?.invokeMethod(
                                STORAGE_RETRIEVER_DELETE_NOTIFY_METHOD_NAME, true
                            )
                        }
                    }
                }
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    // Deletes the passed [File]s on API level 30 or higher i.e. Android 11 +.
    // Automatically notifies [MethodChannel] internally.
    @RequiresApi(Build.VERSION_CODES.R)
    private fun deleteAPILevel30(paths: List<String>) {
        try {
            val pendingIntent = MediaStore.createDeleteRequest(
                context.contentResolver,
                paths.map { path -> parse(path)!! }
            )
            (context as Activity).startIntentSenderForResult(
                pendingIntent.intentSender,
                STORAGE_RETRIEVER_DELETE_REQUEST_CODE,
                null,
                0,
                0,
                0,
                null
            )
            Log.d("Harmonoid", "MediaStore.createDeleteRequest: $paths")
            // Notified through [MainActivity.onActivityResult].
        } catch (e: Exception) {
            Log.d("Harmonoid", "Exception: $paths")
            e.printStackTrace()
            channel?.invokeMethod(
                STORAGE_RETRIEVER_DELETE_NOTIFY_METHOD_NAME, false
            )
        }
    }

    // Deletes the passed [File]s on API level 29 i.e. Android 10.
    // Automatically notifies [MethodChannel] internally.
    //
    // It is possible to delete only a single file on this API level because scoped storage was
    // newly enforced & actual Android API was retarded.
    //
    @RequiresApi(Build.VERSION_CODES.Q)
    private fun deleteAPILevel29(paths: List<String>) {
        if (paths.size == 1) {
            try {
                val response = context.contentResolver.delete(
                    parse(paths.first())!!,
                    null,
                    null
                )
                Log.d(
                    "Harmonoid",
                    "ContentResolver.delete: response = $response"
                )
                channel?.invokeMethod(
                    STORAGE_RETRIEVER_DELETE_NOTIFY_METHOD_NAME, response > 0
                )
            } catch (e: SecurityException) {
                Log.d("Harmonoid", "SecurityException: $paths")
                try {
                    val recoverableSecurityException =
                        e as? RecoverableSecurityException
                    val intentSender =
                        recoverableSecurityException?.userAction?.actionIntent?.intentSender
                    if (intentSender != null) {
                        (context as Activity).startIntentSenderForResult(
                            intentSender,
                            STORAGE_RETRIEVER_DELETE_REQUEST_CODE,
                            // Just pass the path through [Intent] on Android 10.
                            // It needs to be deleted after user approval.
                            Intent(parse(paths.first())!!.toString()),
                            0,
                            0,
                            0,
                            null
                        )
                        // Notified through [MainActivity.onActivityResult].
                    }
                } catch (e: Exception) {
                    Log.d("Harmonoid", "Exception: $paths")
                    e.printStackTrace()
                    channel?.invokeMethod(
                        STORAGE_RETRIEVER_DELETE_NOTIFY_METHOD_NAME, false
                    )
                }
            } catch (e: Exception) {
                Log.d("Harmonoid", "Exception: $paths")
                e.printStackTrace()
                channel?.invokeMethod(
                    STORAGE_RETRIEVER_DELETE_NOTIFY_METHOD_NAME, false
                )
            }
        } else {
            // There is no way to delete multiple files on Android 10.
            // Just return success == false.
            channel?.invokeMethod(
                STORAGE_RETRIEVER_DELETE_NOTIFY_METHOD_NAME, false
            )
        }
    }

    // Converts passed [File] [path] to `content://` URI from [MediaStore].
    // e.g. `content://media/external/audio/media/1234`.
    //
    // Only used on API level 29 or higher.
    //
    private fun parse(path: String): Uri? {
        try {
            val collection =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
                } else {
                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
                }
            // Find [MediaStore.Audio.Media._ID] where [MediaStore.Audio.Media.DATA] i.e. absolute path matches the passed [path].
            val projection = arrayOf(MediaStore.Audio.Media._ID, MediaStore.Audio.Media.DATA)
            val selection = "${MediaStore.Audio.Media.DATA} = ?"
            val selectionArgs = arrayOf(path)
            val sortOrder = "${MediaStore.Audio.Media._ID} ASC"
            val query = context.contentResolver.query(
                collection,
                projection,
                selection,
                selectionArgs,
                sortOrder
            )
            query?.use { cursor ->
                Log.d("Harmonoid", "ContentResolver.query: cursor.count = ${cursor.count}")
                if (cursor.count > 0) {
                    cursor.moveToFirst()
                    val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
                    val dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
                    val id = cursor.getLong(idColumn)
                    val data = cursor.getString(dataColumn)
                    Log.d("Harmonoid", "ContentResolver.query: id = $id")
                    Log.d("Harmonoid", "ContentResolver.query: data = $data")
                    return ContentUris.withAppendedId(collection, id)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        try {
            val collection =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
                } else {
                    MediaStore.Video.Media.EXTERNAL_CONTENT_URI
                }
            // Find [MediaStore.Video.Media._ID] where [MediaStore.Video.Media.DATA] i.e. absolute path matches the passed [path].
            val projection = arrayOf(MediaStore.Video.Media._ID, MediaStore.Video.Media.DATA)
            val selection = "${MediaStore.Video.Media.DATA} = ?"
            val selectionArgs = arrayOf(path)
            val sortOrder = "${MediaStore.Video.Media._ID} ASC"
            val query = context.contentResolver.query(
                collection,
                projection,
                selection,
                selectionArgs,
                sortOrder
            )
            query?.use { cursor ->
                Log.d("Harmonoid", "ContentResolver.query: cursor.count = ${cursor.count}")
                if (cursor.count > 0) {
                    cursor.moveToFirst()
                    val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
                    val dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
                    val id = cursor.getLong(idColumn)
                    val data = cursor.getString(dataColumn)
                    Log.d("Harmonoid", "ContentResolver.query: id = $id")
                    Log.d("Harmonoid", "ContentResolver.query: data = $data")
                    return ContentUris.withAppendedId(collection, id)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        try {
            val collection =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
                } else {
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI
                }
            // Find [MediaStore.Images.Media._ID] where [MediaStore.Images.Media.DATA] i.e. absolute path matches the passed [path].
            val projection = arrayOf(MediaStore.Images.Media._ID, MediaStore.Images.Media.DATA)
            val selection = "${MediaStore.Images.Media.DATA} = ?"
            val selectionArgs = arrayOf(path)
            val sortOrder = "${MediaStore.Images.Media._ID} ASC"
            val query = context.contentResolver.query(
                collection,
                projection,
                selection,
                selectionArgs,
                sortOrder
            )
            query?.use { cursor ->
                Log.d("Harmonoid", "ContentResolver.query: cursor.count = ${cursor.count}")
                if (cursor.count > 0) {
                    cursor.moveToFirst()
                    val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
                    val dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
                    val id = cursor.getLong(idColumn)
                    val data = cursor.getString(dataColumn)
                    Log.d("Harmonoid", "ContentResolver.query: id = $id")
                    Log.d("Harmonoid", "ContentResolver.query: data = $data")
                    return ContentUris.withAppendedId(collection, id)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }
}
