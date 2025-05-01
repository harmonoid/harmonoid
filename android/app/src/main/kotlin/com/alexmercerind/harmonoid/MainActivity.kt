package com.alexmercerind.harmonoid

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.ryanheise.audioservice.AudioServiceActivity
import com.ryanheise.audioservice.AudioServicePlugin
import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import kotlin.io.path.Path

class MainActivity : AudioServiceActivity() {
    companion object {
        private const val INTENT_CONTROLLER_CHANNEL_NAME: String = "com.alexmercerind.harmonoid/intent_controller"
        private const val STORAGE_CONTROLLER_CHANNEL_NAME: String = "com.alexmercerind.harmonoid/storage_controller"
        private const val UTILS_CHANNEL_NAME: String = "com.alexmercerind.harmonoid/utils"

        private const val NOTIFY_INTENT_METHOD_NAME = "notifyIntent"

        private const val SCHEME_CONTENT = "content"
        private const val SCHEME_FILE = "file"
        private const val SCHEME_HTTP = "http"
        private const val SCHEME_HTTPS = "https"
    }

    private var intentControllerMethodChannel: MethodChannel? = null
    private var storageControllerMethodChannel: MethodChannel? = null
    private var utilsMethodChannel: MethodChannel? = null
    private var uri: String? = null

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        AudioServicePlugin.disposeFlutterEngine()
        return super.provideFlutterEngine(context)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        Log.d(TAG, this.storageDirectories.toString())

        intentControllerMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INTENT_CONTROLLER_CHANNEL_NAME).apply {
            setMethodCallHandler { _, result -> result.success(uri) }
        }
        storageControllerMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STORAGE_CONTROLLER_CHANNEL_NAME).apply {
            setMethodCallHandler(StorageControllerMethodCallHandler(this@MainActivity, this))
        }
        utilsMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, UTILS_CHANNEL_NAME).apply {
            setMethodCallHandler(UtilsMethodCallHandler(this@MainActivity))
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            StorageControllerMethodCallHandler.DELETE_REQUEST_CODE -> {
                if (Build.VERSION.SDK_INT == Build.VERSION_CODES.Q && resultCode == RESULT_OK && data != null) {
                    runCatching { context.contentResolver.delete(Uri.parse(data.action), null, null) }
                }
                storageControllerMethodChannel?.invokeMethod(StorageControllerMethodCallHandler.NOTIFY_DELETE_METHOD_NAME, resultCode == RESULT_OK)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        installSplashScreen()
        handleIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    @Synchronized
    private fun handleIntent(intent: Intent?) {
        if (intent == null) return
        Log.d(TAG, intent.action.toString())
        Log.d(TAG, intent.data.toString())
        Log.d(TAG, intent.scheme.toString())
        Log.d(TAG, intent.type.toString())
        val result = when (intent.data?.scheme?.lowercase()) {
            SCHEME_CONTENT -> {
                val resolveInfos = context.packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
                for (resolveInfo in resolveInfos) {
                    val packageName = resolveInfo.activityInfo.packageName
                    context.grantUriPermission(packageName, intent.data, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                File(Path(this.cacheDirectory, this::class.java.name, intent.data.toString().md5).toString()).run {
                    if (length() == 0L) {
                        parentFile?.run { deleteRecursively(); mkdirs() }
                        contentResolver.openInputStream(intent.data!!).use { it?.copyTo(FileOutputStream(this)) }
                    }
                    "$SCHEME_FILE://${absolutePath}"
                }
            }

            SCHEME_FILE, SCHEME_HTTP, SCHEME_HTTPS -> intent.data.toString()

            else -> null
        }

        Log.d(TAG, uri.toString())

        if (result != null && result != uri) {
            uri = result
            intentControllerMethodChannel?.invokeMethod(NOTIFY_INTENT_METHOD_NAME, uri)
        }
    }
}
