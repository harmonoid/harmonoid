package com.alexmercerind.harmonoid

import android.app.Activity
import android.os.Environment
import java.io.File
import java.security.MessageDigest

val Activity.storageDirectories: List<String> get() = getExternalFilesDirs(null).map { file -> file.absolutePath.split("/Android/").first() }

val Activity.cacheDirectory: String get() = getExternalFilesDirs(null).first().absolutePath

val Activity.defaultMediaLibraryDirectory: String get() = File(getExternalFilesDirs(null).first().absolutePath.split("/Android/").first(), Environment.DIRECTORY_MUSIC).absolutePath

@OptIn(ExperimentalStdlibApi::class)
val String.md5 get() = MessageDigest.getInstance("MD5").digest(this.toByteArray()).toHexString()
