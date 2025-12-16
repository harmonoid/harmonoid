package com.alexmercerind.harmonoid

import android.app.Activity
import android.os.Environment
import android.widget.Toast
import java.io.File
import java.security.MessageDigest

val Activity.storageDirectories: List<String>
    get() = runCatching {
        getExternalFilesDirs(null).map { file -> file.absolutePath.split("/Android/").first() }
    }.getOrElse { exception ->
        exception.printStackTrace()
        Toast.makeText(this, "Unable to access storage", Toast.LENGTH_LONG).show()
        throw exception
    }

val Activity.cacheDirectory: String
    get() = runCatching {
        getExternalFilesDirs(null).first().absolutePath
    }.getOrElse { exception ->
        exception.printStackTrace()
        Toast.makeText(this, "Unable to access storage", Toast.LENGTH_LONG).show()
        throw exception
    }

val Activity.defaultMediaLibraryDirectory: String
    get() = runCatching {
        File(getExternalFilesDirs(null).first().absolutePath.split("/Android/").first(), Environment.DIRECTORY_MUSIC).absolutePath
    }.getOrElse { exception ->
        exception.printStackTrace()
        Toast.makeText(this, "Unable to access storage", Toast.LENGTH_LONG).show()
        throw exception
    }

@OptIn(ExperimentalStdlibApi::class)
val String.md5 get() = MessageDigest.getInstance("MD5").digest(this.toByteArray()).toHexString()
