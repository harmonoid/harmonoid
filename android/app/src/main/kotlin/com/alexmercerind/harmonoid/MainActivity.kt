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
import java.security.MessageDigest
import kotlin.io.path.Path

class MainActivity : AudioServiceActivity() {
    companion object {
        private const val TAG = "Harmonoid"

        private const val INTENT_CONTROLLER_CHANNEL_NAME: String = "com.alexmercerind.harmonoid/intent_controller"
        private const val STORAGE_CONTROLLER_CHANNEL_NAME: String = "com.alexmercerind.harmonoid/storage_controller"

        private const val NOTIFY_INTENT_METHOD_NAME = "notifyIntent"

        private const val SCHEME_CONTENT = "content"
        private const val SCHEME_FILE = "file"
        private const val SCHEME_HTTP = "http"
        private const val SCHEME_HTTPS = "https"
    }

    private var intentControllerMethodChannel: MethodChannel? = null
    private var storageControllerMethodChannel: MethodChannel? = null
    private var uri: String? = null

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        AudioServicePlugin.disposeFlutterEngine()
        return super.provideFlutterEngine(context)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        Log.d(TAG, context.getExternalFilesDirs(null).map { file -> file.absolutePath }.toString())

        intentControllerMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INTENT_CONTROLLER_CHANNEL_NAME).apply {
            setMethodCallHandler { _, result -> result.success(uri) }
        }
        storageControllerMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STORAGE_CONTROLLER_CHANNEL_NAME).apply {
            setMethodCallHandler(StorageControllerMethodCallHandler(this@MainActivity, this))
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
                contentResolver.openInputStream(intent.data!!).use { stream ->
                    val file = File(Path(context.getExternalFilesDir(null)!!.absolutePath, "Intent", intent.data.toString().md5()).toString())
                    if (!file.exists()) {
                        if (file.parentFile?.exists() == true) {
                            file.parentFile?.deleteRecursively()
                        }
                        file.parentFile?.mkdirs()
                        file.createNewFile()
                        stream?.copyTo(FileOutputStream(file))
                    }
                    "$SCHEME_FILE://${file.absolutePath}"
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

    @OptIn(ExperimentalStdlibApi::class)
    private fun String.md5() = MessageDigest.getInstance("MD5").digest(this.toByteArray()).toHexString()
}
