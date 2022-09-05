/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

package com.alexmercerind.harmonoid

import android.os.Bundle
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
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

private const val INTENT_CHANNEL_NAME: String = "com.alexmercerind.harmonoid";
private const val METADATA_RETRIEVER_CHANNEL_NAME: String = "com.alexmercerind.harmonoid.MetadataRetriever";
private const val STORAGE_RETRIEVER_CHANNEL_NAME: String = "com.alexmercerind.harmonoid.StorageRetriever";

class MainActivity : AudioServiceActivity() {
    private var channel: MethodChannel? = null
    private var uri: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        Log.d(
            "Harmonoid",
            context.getExternalFilesDirs(null).map { file -> file.absolutePath }.toString()
        )
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            INTENT_CHANNEL_NAME
        )
        channel?.setMethodCallHandler { _, result ->
            result.success(uri)
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METADATA_RETRIEVER_CHANNEL_NAME
        ).setMethodCallHandler(MetadataRetriever())
        // Gets the absolute paths for internal storage & external SD card.
        // This is the only solution.
        // By default, [getExternalFilesDirs] returns the application specific & private path e.g.
        // `/storage/emulated/0/Android/data/com.alexmercerind.harmonoid/files`.
        // This is because Android is promoting Scoped Storage & [MediaStore], which unfortunately
        // fail many of our use cases like custom or multiple directory selection for music indexing
        // or looking for .LRC files in the same directory as audio file etc.
        // This would also mean that all the application (in-theory) would have to be additionally
        // written in Kotlin just to support Android, because existing media library manager &
        // indexer written in Dart is completely file-system based, since Windows & Linux have no
        // such concepts as Android recently redundantly introduced.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            STORAGE_RETRIEVER_CHANNEL_NAME
        ).setMethodCallHandler { call, result ->
            if (call.method.equals("volumes")) {
                val volumes: List<String> = context.getExternalFilesDirs(null).map { file -> file.absolutePath.split("/Android/")[0] }
                Log.d("Harmonoid", volumes.toString())
                result.success(volumes)
            } else if (call.method.equals("cache")) {
                val cache: String? = context.getExternalFilesDirs(null).firstOrNull()?.absolutePath
                Log.d("Harmonoid", cache.toString())
                result.success(cache)
            } else {
                result.notImplemented()
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
                // Removing all special characters to prevent any issues with URI deserialization/
                // serialization inside Flutter or file creation.
                val fileName = intent.data.toString().split("/").toList().lastOrNull()
                    ?.replace("[^a-zA-Z0-9]".toRegex(), "")
                Log.d("Harmonoid", fileName.toString())
                // If file name is null, then a random integer value is used as the temporary file's name.
                val path = "$intentFilesDirAbsolutePath/${
                    fileName ?: Random().nextInt(Integer.MAX_VALUE).toString()
                        .replace("[\\\\/:*?\"<>| ]".toRegex(), "")
                }"
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
                    // Recursively create all the directories & subdirectories to the temporary file,
                    // and copy the stream to it after creation of file itself.
                    File(intentFilesDirAbsolutePath).mkdirs()
                    if (!File(path).exists()) {
                        File(path).createNewFile()
                    }
                    inputStream?.copyTo(FileOutputStream(path))
                    result = "file://$path"
                    Log.d("Harmonoid", path)
                }
            }
            if (!arrayListOf(null, uri).contains(result)) {
                // Notify the newly opened file through the platform channel.
                uri = result
                channel?.invokeMethod("Harmonoid", uri)
                Log.d("Harmonoid", uri.toString())
            }
        }
    }
}
