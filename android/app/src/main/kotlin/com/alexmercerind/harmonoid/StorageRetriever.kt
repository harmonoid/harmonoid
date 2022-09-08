/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

package com.alexmercerind.harmonoid

import android.content.Context
import io.flutter.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

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
class StorageRetriever(private val context: Context): MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when {
            call.method.equals("volumes") -> {
                val volumes: List<String> = context.getExternalFilesDirs(null).map { file -> file.absolutePath.split("/Android/")[0] }
                Log.d("Harmonoid", volumes.toString())
                result.success(volumes)
            }
            call.method.equals("cache") -> {
                val cache: String? = context.getExternalFilesDirs(null).firstOrNull()?.absolutePath
                Log.d("Harmonoid", cache.toString())
                result.success(cache)
            }
            call.method.equals("version") -> {
                val version: Int = android.os.Build.VERSION.SDK_INT
                Log.d("Harmonoid", version.toString())
                result.success(version)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
