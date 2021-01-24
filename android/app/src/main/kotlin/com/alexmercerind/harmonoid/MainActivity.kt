package com.alexmercerind.harmonoid

import io.flutter.embedding.android.FlutterActivity
/*
  https://stackoverflow.com/a/59484832/12825435
*/
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.alexmercerind.harmonoid/openFile"

    var openPath: String? = null
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getOpenFile" -> {
                    result.success(openPath)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleOpenFileUrl(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleOpenFileUrl(intent)
    }

    private fun handleOpenFileUrl(intent: Intent?) {
        val path = intent?.data?.path
        if (path != null) {
            openPath = path
        }
    }
}
