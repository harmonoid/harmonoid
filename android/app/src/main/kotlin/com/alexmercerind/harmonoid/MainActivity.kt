/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

package com.alexmercerind.harmonoid

import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.net.Uri
import android.os.Build
import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.util.Random
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import com.ryanheise.audioservice.AudioServiceActivity
import java.math.BigInteger
import java.security.MessageDigest

private const val METADATA_RETRIEVER_CHANNEL_NAME: String =
    "com.alexmercerind.harmonoid.MetadataRetriever"
private const val STORAGE_RETRIEVER_CHANNEL_NAME: String =
    "com.alexmercerind.harmonoid.StorageRetriever"
private const val INTENT_RETRIEVER_CHANNEL_NAME: String =
    "com.alexmercerind.harmonoid.IntentRetriever"

class MainActivity : AudioServiceActivity() {
    private var metadataRetrieverChannel: MethodChannel? = null
    private var storageRetrieverChannel: MethodChannel? = null
    private var intentRetrieverChannel: MethodChannel? = null
    private var uri: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        Log.d(
            "Harmonoid",
            context.getExternalFilesDirs(null).map { file -> file.absolutePath }.toString()
        )
        metadataRetrieverChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METADATA_RETRIEVER_CHANNEL_NAME
        )
        storageRetrieverChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            STORAGE_RETRIEVER_CHANNEL_NAME
        )
        intentRetrieverChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            INTENT_RETRIEVER_CHANNEL_NAME
        )
        metadataRetrieverChannel?.setMethodCallHandler(MetadataRetriever())
        storageRetrieverChannel?.setMethodCallHandler(
            StorageRetriever(
                storageRetrieverChannel,
                context
            )
        )
        intentRetrieverChannel?.setMethodCallHandler { _, result ->
            result.success(uri)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        // From [StorageRetriever] class.
        when (requestCode) {
            STORAGE_RETRIEVER_DELETE_REQUEST_CODE -> {
                // Android 10 is retarded. Sorry, all Android versions after 9 are retarded.
                // [File] needs to be deleted afterwards here.
                if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q && resultCode == RESULT_OK && data != null) {
                    try {
                        context.contentResolver.delete(
                            Uri.parse(data.action),
                            null,
                            null
                        )
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
                Log.d("Harmonoid", "STORAGE_RETRIEVER_DELETE_NOTIFY_METHOD_NAME: $resultCode")
                storageRetrieverChannel?.invokeMethod(
                    STORAGE_RETRIEVER_DELETE_NOTIFY_METHOD_NAME,
                    resultCode == RESULT_OK
                )
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        installSplashScreen()
        receiveIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        receiveIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        receiveIntent(intent)
    }

    @Synchronized
    private fun receiveIntent(intent: Intent?) {
        // This has been configured to work correctly with android:launchMode as singleTask.
        if (intent != null) {
            var result: String? = null
            Log.d("Harmonoid", intent.scheme.toString())
            Log.d("Harmonoid", intent.action.toString())
            Log.d("Harmonoid", intent.type.toString())
            Log.d("Harmonoid", intent.data.toString())
            if (arrayListOf("file", "http").contains(intent.data?.scheme)) {
                result = intent.data.toString()
            }
            // Separately handle modern content:// URIs in Android.
            else if (intent.data?.scheme == "content") {
                val resolveInfoList: List<ResolveInfo> = context.packageManager
                    .queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
                // TODO: [queryIntentActivities] with [ResolveInfoFlags] overload seems to be not working on Android 13.
                // val resolveInfoList: List<ResolveInfo> =
                //     if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                //         context.packageManager
                //             .queryIntentActivities(
                //                 intent,
                //                 PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_DEFAULT_ONLY.toLong())
                //             )
                //     } else {
                //         context.packageManager
                //             .queryIntentActivities(
                //                 intent,
                //                 PackageManager.MATCH_DEFAULT_ONLY
                //             )
                //     }
                // Not requesting Intent.FLAG_GRANT_READ_URI_PERMISSION.
                // Since, we are never going to write the file which is being opened.
                //
                // It requires different approach in new Android versions to write the opened file.
                // Likely through ACTION_OPEN_DOCUMENT & FileDescriptor.
                // Though, since this seems to work perfectly. It's good to go.
                for (resolveInfo in resolveInfoList) {
                    val packageName: String = resolveInfo.activityInfo.packageName
                    context.grantUriPermission(
                        packageName,
                        intent.data, Intent.FLAG_GRANT_READ_URI_PERMISSION
                    )
                }
                // In general, the idea is to copy the file to a local temporary file with unique
                // URI received through intent, inside app's cache directory.
                //
                // Get reference to the InputStream from this content:// URI.
                val inputStream: InputStream? = contentResolver.openInputStream(intent.data!!)
                // The cache directory of the application. Equivalent to getExternalStorageDirectory
                // in package:path_provider of Flutter.
                var externalFilesDirAbsolutePath = context.getExternalFilesDir(null)?.absolutePath!!
                if (externalFilesDirAbsolutePath.endsWith("/")) {
                    externalFilesDirAbsolutePath = externalFilesDirAbsolutePath.substring(
                        0, externalFilesDirAbsolutePath.length - 1
                    )
                }
                // Saving the file in "Intents" subdirectory, for easy clean-up the cache in future.
                val intentFilesDirAbsolutePath = "$externalFilesDirAbsolutePath/Intents"
                Log.d("Harmonoid", intentFilesDirAbsolutePath)
                // Last segment of the URI is interpreted as the file path.
                // Removing all special characters to prevent any issues with URI deserialization/serialization inside Flutter or file creation.
                val fileName = intent.data.toString().split("/").toList().lastOrNull()
                    ?.replace("[^a-zA-Z0-9]".toRegex(), "")
                Log.d("Harmonoid", fileName.toString())
                // If file name is null, then a random integer value is used as the temporary file's name.
                // Hashing the resulting [fileName] as MD5. This will prevent any file name too long [IOException]s.
                val path = "$intentFilesDirAbsolutePath/${getFileNameIdentifier(fileName)}"
                result = "file://$path"
                Log.d("Harmonoid", path)
                // Only create/copy the content from the [Intent] if same file does not exist.
                if (!File(path).exists()) {
                    Log.d("Harmonoid", path)
                    // Delete the directory where the temporary files are placed. This is because
                    // some previous intent handling would've resulted in file creations here.
                    // This wastage of space can quickly get out of hands.
                    if (File(intentFilesDirAbsolutePath).exists()
                        && File(intentFilesDirAbsolutePath).isDirectory
                    ) {
                        File(intentFilesDirAbsolutePath).deleteRecursively()
                    }
                    // Recursively create all the directories & subdirectories to the temporary file, and copy the stream to it after creation of file itself.
                    File(intentFilesDirAbsolutePath).mkdirs()
                    if (!File(path).exists()) {
                        File(path).createNewFile()
                    }
                    inputStream?.copyTo(FileOutputStream(path))
                }
            }
            if (!arrayListOf(null, uri).contains(result)) {
                // Notify the newly opened file through the platform channel.
                uri = result
                intentRetrieverChannel?.invokeMethod("Harmonoid", uri)
                Log.d("Harmonoid", uri.toString())
            }
        }
    }

    private fun getFileNameIdentifier(input: String?): String {
        val instance = MessageDigest.getInstance("MD5")
        return if (input != null) {
            val result =
                BigInteger(
                    1,
                    instance.digest(input.toByteArray())
                ).toString(16).padStart(32, '0')
            val identifier = result.replace("[^a-zA-Z0-9]".toRegex(), "")
            Log.d("Harmonoid", identifier)
            identifier
        } else {
            // Shouldn't ever happen, but still present as a fallback.
            Random().nextInt(Integer.MAX_VALUE).toString()
        }
    }
}
