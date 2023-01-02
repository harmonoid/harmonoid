/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

package com.alexmercerind.harmonoid;

import java.util.Collections;
import java.util.HashMap;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

import java9.util.concurrent.CompletableFuture;

import android.media.MediaExtractor;
import android.media.MediaFormat;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.media.MediaMetadataRetriever;
import android.webkit.MimeTypeMap;

class MediaMetadataRetrieverExt extends MediaMetadataRetriever {
    public MediaMetadataRetrieverExt() {
        super();
    }

    // Just for preventing any [Exception] when reading a metadata key.
    // Better is just to avoid, instead of crashing.
    private String readKey(int keyCode) {
        try {
            return extractMetadata(keyCode);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public HashMap<String, String> read() {
        HashMap<String, String> metadata = new HashMap<>();
        metadata.put("METADATA_KEY_CD_TRACK_NUMBER", readKey(METADATA_KEY_CD_TRACK_NUMBER));
        metadata.put("METADATA_KEY_ALBUM", readKey(METADATA_KEY_ALBUM));
        metadata.put("METADATA_KEY_ARTIST", readKey(METADATA_KEY_ARTIST));
        metadata.put("METADATA_KEY_AUTHOR", readKey(METADATA_KEY_AUTHOR));
        metadata.put("METADATA_KEY_COMPOSER", readKey(METADATA_KEY_COMPOSER));
        metadata.put("METADATA_KEY_DATE", readKey(METADATA_KEY_DATE));
        metadata.put("METADATA_KEY_GENRE", readKey(METADATA_KEY_GENRE));
        metadata.put("METADATA_KEY_TITLE", readKey(METADATA_KEY_TITLE));
        metadata.put("METADATA_KEY_YEAR", readKey(METADATA_KEY_YEAR));
        metadata.put("METADATA_KEY_DURATION", readKey(METADATA_KEY_DURATION));
        metadata.put("METADATA_KEY_NUM_TRACKS", readKey(METADATA_KEY_NUM_TRACKS));
        metadata.put("METADATA_KEY_WRITER", readKey(METADATA_KEY_WRITER));
        metadata.put("METADATA_KEY_MIMETYPE", readKey(METADATA_KEY_MIMETYPE));
        metadata.put("METADATA_KEY_ALBUMARTIST", readKey(METADATA_KEY_ALBUMARTIST));
        metadata.put("METADATA_KEY_DISC_NUMBER", readKey(METADATA_KEY_DISC_NUMBER));
        metadata.put("METADATA_KEY_COMPILATION", readKey(METADATA_KEY_COMPILATION));
        metadata.put("METADATA_KEY_HAS_AUDIO", readKey(METADATA_KEY_HAS_AUDIO));
        metadata.put("METADATA_KEY_HAS_VIDEO", readKey(METADATA_KEY_HAS_VIDEO));
        metadata.put("METADATA_KEY_VIDEO_WIDTH", readKey(METADATA_KEY_VIDEO_WIDTH));
        metadata.put("METADATA_KEY_VIDEO_HEIGHT", readKey(METADATA_KEY_VIDEO_HEIGHT));
        metadata.put("METADATA_KEY_BITRATE", readKey(METADATA_KEY_BITRATE));
        Log.d("Harmonoid", metadata.toString());
        // Remove all entries having `null` value from the `metadata`.
        metadata.values().removeAll(Collections.singleton(null));
        return metadata;
    }
}

public class MetadataRetriever implements MethodCallHandler {
    @SuppressWarnings("UnusedDeclaration")
    @Override
    public void onMethodCall(@NonNull final MethodCall call, @NonNull final Result result) {
        // Passed [uri] inside the arguments must be a String interpretation of a URI, which follows a scheme such as `file://` or `http://` etc.
        // Where as, [albumArtDirectory] must be a direct path to the file system directory where the cover art will be extracted (not a URI).
        if (call.method.equals("metadata")) {
            final String[] uri = {call.argument("uri")};
            final String[] albumArtDirectory = {call.argument("albumArtDirectory")};
            final Boolean[] waitUntilAlbumArtIsSaved = {call.argument("waitUntilAlbumArtIsSaved")};
            if (waitUntilAlbumArtIsSaved[0] == null) {
                waitUntilAlbumArtIsSaved[0] = false;
            }
            if (uri[0] != null) {
                Log.d("Harmonoid", uri[0]);
            }
            // Run [MediaMetadataRetriever] on another thread. Extracting metadata of a [File] is a heavy operation & causes substantial jitter in the UI.
            CompletableFuture.runAsync(() -> {
                final MediaMetadataRetrieverExt retriever = new MediaMetadataRetrieverExt();
                // Try to get the [FileInputStream] from the passed [uri].
                try {
                    // Only used for `file://` scheme.
                    FileInputStream input = null;
                    HashMap<String, String> metadata = new HashMap<String, String>();
                    // Handle `file://`.
                    if (uri[0].toLowerCase().startsWith("file://")) {
                        input = new FileInputStream(Uri.parse(uri[0]).getPath());
                        // Set data source using [FileDescriptor], which tends to be safer.
                        retriever.setDataSource(input.getFD());
                        metadata = retriever.read();
                        // Return the metadata.
                        final HashMap<String, String> response = metadata;
                        if (!waitUntilAlbumArtIsSaved[0]) {
                            new Handler(Looper.getMainLooper()).post(() -> result.success(response));
                        }
                    } else {
                        // Handle other URI schemes. Expected to be network URLs. Hope for the best!
                        retriever.setDataSource(uri[0], new HashMap<>());
                        metadata = retriever.read();
                        final HashMap<String, String> response = metadata;
                        if (!waitUntilAlbumArtIsSaved[0]) {
                            new Handler(Looper.getMainLooper()).post(() -> result.success(response));
                        }
                    }
                    // Now proceed to save the album art in background.
                    String trackName = metadata.get("METADATA_KEY_TITLE");
                    // NOTE: Following same contract as Harmonoid. Only used to save the album art locally.
                    if (trackName == null) {
                        // If [trackName] is found null, we extract a human-understandable [String] from the [File]'s original name.
                        if (uri[0].endsWith("/")) {
                            // Remove trailing `/`.
                            uri[0] = uri[0].substring(0, uri[0].length() - 1);
                        }
                        // Split across last `/` in the URI & keep it as [trackName].
                        trackName = uri[0].split("/")[uri[0].split("/").length - 1];
                        // We need to decode the URI component to get actual [File]'s name.
                        // Only done for `file://` scheme URIs. See Harmonoid's Track fromJson factory constructor for more information.
                        if (uri[0].toLowerCase().startsWith("file://")) {
                            try {
                                trackName = URLDecoder.decode(trackName, StandardCharsets.UTF_16.toString());
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    }
                    String albumName = metadata.get("METADATA_KEY_ALBUM");
                    if (albumName == null) {
                        albumName = "Unknown Album";
                    }
                    String albumArtistName = metadata.get("METADATA_KEY_ALBUMARTIST");
                    if (albumArtistName == null) {
                        albumArtistName = "Unknown Artist";
                    }
                    // Remove trailing `/` from `albumArtDirectory` path.
                    if (albumArtDirectory[0].endsWith("/")) {
                        albumArtDirectory[0] = albumArtDirectory[0].substring(0, albumArtDirectory[0].length() - 1);
                    }
                    // Final album art [File].
                    final File file = new File(
                            String.format(
                                    "%s/%s.PNG",
                                    albumArtDirectory[0],
                                    String.format(
                                            "%s%s%s",
                                            trackName,
                                            albumName,
                                            albumArtistName
                                    ).replaceAll(
                                            "[\\\\/:*?\"<>| ]"
                                            , ""
                                    )
                            )
                    );
                    Log.d("Harmonoid", file.getAbsolutePath());
                    try {
                        byte[] embeddedPicture = retriever.getEmbeddedPicture();
                        if (embeddedPicture != null) {
                            // Recursively create directories to the specified album art [File] & also create the [File] if not already present at the location.
                            final boolean mkdirs = new File(albumArtDirectory[0]).mkdirs();
                            if (!file.exists()) {
                                final boolean created = file.createNewFile();
                            }
                            final FileOutputStream output = new FileOutputStream(file);
                            output.write(retriever.getEmbeddedPicture());
                            output.close();
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    try {
                        retriever.release();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    try {
                        if (input != null) {
                            input.close();
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    if (waitUntilAlbumArtIsSaved[0]) {
                        // Adding some voluntary delay to ensure presence of saved album art on storage.
                        // There seems to be some race condition.
                        try {
                            Thread.sleep(100);
                        } catch(Exception e) {
                            e.printStackTrace();
                        }
                        HashMap<String, String> response = metadata;
                        new Handler(Looper.getMainLooper()).post(() -> result.success(response));
                    }
                }
                // Return fallback [metadata] [HashMap], with only [uri] key present inside it.
                // In case a [FileNotFoundException] or [IOException] was thrown.
                catch (Exception exception) {
                    exception.printStackTrace();
                    new Handler(Looper.getMainLooper()).post(() -> result.success(new HashMap<String, String>()));
                }
            });
        } else if (call.method.equals("format")) {
            final String uri = call.argument("uri");
            final HashMap<String, Object> response = new HashMap<>();
            // Only supports FILE scheme.
            if (uri != null && uri.toLowerCase().startsWith("file://")) {
                CompletableFuture.runAsync(() -> {
                    MediaExtractor extractor = null;
                    FileInputStream input = null;
                    try {
                        extractor = new MediaExtractor();
                        // Set data source using [FileDescriptor], which tends to be safer.
                        input = new FileInputStream(Uri.parse(uri).getPath());
                        extractor.setDataSource(input.getFD());
                        Log.d("Harmonoid", String.valueOf(extractor.getTrackCount()));
                        final MediaFormat format = extractor.getTrackFormat(0);
                        try {
                            final int channelCount = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT);
                            response.put("channelCount", channelCount);
                        } catch (NullPointerException e) {
                            e.printStackTrace();
                        }
                        try {
                            final int bitrate = format.getInteger(MediaFormat.KEY_BIT_RATE);
                            response.put("bitrate", bitrate);
                        } catch (NullPointerException e) {
                            e.printStackTrace();
                        }
                        try {
                            final int sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE);
                            response.put("sampleRate", sampleRate);
                        } catch (NullPointerException e) {
                            e.printStackTrace();
                        }
                        try {
                            final int channelCount = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT);
                            response.put("channelCount", channelCount);
                        } catch (NullPointerException e) {
                            e.printStackTrace();
                        }
                        try {
                            final String mime = format.getString(MediaFormat.KEY_MIME);
                            final String extension = MimeTypeMap.getSingleton().getExtensionFromMimeType(mime);
                            response.put("extension", extension);
                        } catch (NullPointerException e) {
                            e.printStackTrace();
                        }
                        // [MediaExtractor] does not read the bitrate & mime in some situations.
                        // I've noticed this particularly with some OPUS [File]s.
                        // [MediaMetadataRetriever] is used as a fallback.
                        if (!response.containsKey("bitrate")) {
                            try {
                                final MediaMetadataRetriever retriever = new MediaMetadataRetriever();
                                retriever.setDataSource(input.getFD());
                                response.put(
                                        "bitrate",
                                        Integer.parseInt(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE))
                                );
                                retriever.release();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                        try {
                            if (!response.containsKey("extension") || response.get("extension") == null) {
                                final String[] data = Uri.parse(uri).getPath().split("\\.");
                                response.put("extension", data[data.length - 1].toUpperCase());
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        new Handler(Looper.getMainLooper()).post(() -> result.success(response));
                        extractor.release();
                    } catch (Exception e) {
                        e.printStackTrace();
                        new Handler(Looper.getMainLooper()).post(() -> result.success(response));
                        try {
                            if (extractor != null) {
                                extractor.release();
                            }
                        } catch (Exception exception) {
                            exception.printStackTrace();
                        }
                    }
                });
            } else {
                result.success(response);
            }
        } else {
            result.notImplemented();
        }
    }
}
