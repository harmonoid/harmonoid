package com.alexmercerind.harmonoid

import android.app.Activity
import android.widget.Toast
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class UtilsMethodCallHandler(private val activity: Activity) : MethodChannel.MethodCallHandler {
    companion object {
        private const val MOVE_TASK_TO_BACK_METHOD_NAME = "moveTaskToBack"
        private const val SHOW_TOAST_METHOD_NAME = "showToast"

        private const val SHOW_TOAST_ARG_TEXT = "text"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            MOVE_TASK_TO_BACK_METHOD_NAME -> {
                activity.moveTaskToBack(true)
                result.success(null)
            }

            SHOW_TOAST_METHOD_NAME -> {
                val text = call.argument<String>(SHOW_TOAST_ARG_TEXT)
                Toast.makeText(activity, text, Toast.LENGTH_SHORT).show()
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }
}
