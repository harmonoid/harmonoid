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
import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.util.Random
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    private var channel: MethodChannel? = null
    private var uri: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        channel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "com.alexmercerind.harmonoid"
        )
        channel?.setMethodCallHandler { _, result ->
            result.success(uri)
        }
        MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "com.alexmercerind.harmonoid.MetadataRetriever"
        ).setMethodCallHandler(MetadataRetriever())
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
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
                // If file name is null, then a random integer value is used as the temporary file's
                // name. The file name is then parsed using URLDecode.decode, which removes any of
                // ambiguity that can be caused by parsing the final URI by Dart's Uri.parse.
                // Since, decoding of the URI component may result in some illegal file path
                // characters, they are later on removed using a simple regex.
                val path = "$intentFilesDirAbsolutePath/${
                    Random().nextInt(Integer.MAX_VALUE).toString().replace("[\\\\/:*?\"<>| ]".toRegex(), "")
                }"
                Log.d("Harmonoid", path)
                // Delete the directory where the temporary files are placed. This is because
                // some previous intent handling would've resulted in file creations here.
                // This wastage of space can quickly get out of hands.
                if (File(intentFilesDirAbsolutePath).exists()
                        && File(intentFilesDirAbsolutePath).isDirectory) {
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
            if (!arrayListOf(null, uri).contains(result)) {
                // Notify the newly opened file through the platform channel.
                uri = result
                channel?.invokeMethod("Harmonoid", uri)
                Log.d("Harmonoid", uri.toString())
            }
        }
    }
}
