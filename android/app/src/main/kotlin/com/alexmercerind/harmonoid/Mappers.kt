package com.alexmercerind.harmonoid

import android.app.Activity
import android.os.Environment
import java.security.MessageDigest
import kotlin.io.path.Path

val Activity.storageDirectories: List<String> get() = getExternalFilesDirs(null).map { file -> file.absolutePath.split("/Android/")[0] }

val Activity.cacheDirectory: String get() = getExternalFilesDirs(null).first().absolutePath

val Activity.defaultMediaLibraryDirectory get() = Path(getExternalFilesDirs(null).first().absolutePath.split("/Android/")[0], Environment.DIRECTORY_MUSIC).toString()

@OptIn(ExperimentalStdlibApi::class)
val String.md5 get() = MessageDigest.getInstance("MD5").digest(this.toByteArray()).toHexString()
