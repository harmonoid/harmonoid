/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020 & onwards, Yehuda Kremer <yehudakremer@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:media_engine/media_engine.dart';
import 'package:media_library/media_library.dart';
import 'package:safe_local_storage/safe_local_storage.dart';

import 'package:harmonoid/core/playback.dart';
import 'package:harmonoid/utils/metadata_retriever.dart';

extension IterableExtension<T> on Iterable<T> {
  /// Return distinct array by comparing hash codes.
  Iterable<T> distinct() {
    var distinct = <T>[];
    this.forEach((element) {
      if (!distinct.contains(element)) distinct.add(element);
    });

    return distinct;
  }
}

extension StringExtension on String {
  /// Return modified string which results in prettified [TextOverflow.ellipsis] effect.
  get overflow => Characters(this)
      .replaceAll(Characters(''), Characters('\u{200B}'))
      .toString();

  /// Return modified string with all illegal file system path characters removed.
  get safePath => replaceAll(RegExp(kArtworkFileNameRegex), '');
}

extension DurationExtension on Duration {
  /// Return [Duration] as typical formatted string.
  String get label {
    if (this > Duration(days: 1)) {
      final days = inDays.toString().padLeft(3, '0');
      final hours = (inHours - (inDays * 24)).toString().padLeft(2, '0');
      final minutes = (inMinutes - (inHours * 60)).toString().padLeft(2, '0');
      final seconds = (inSeconds - (inMinutes * 60)).toString().padLeft(2, '0');
      return '$days:$hours:$minutes:$seconds';
    } else if (this > Duration(hours: 1)) {
      final hours = inHours.toString().padLeft(2, '0');
      final minutes = (inMinutes - (inHours * 60)).toString().padLeft(2, '0');
      final seconds = (inSeconds - (inMinutes * 60)).toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    } else {
      final minutes = inMinutes.toString().padLeft(2, '0');
      final seconds = (inSeconds - (inMinutes * 60)).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    }
  }
}

extension DateTimeExtension on DateTime {
  /// Format [DateTime] as `DD-MM-YYYY`.
  String get label =>
      '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
}

extension TrackExtension on Track {
  /// Whether the [Track] actually has meaningful actual track artists from metadata tags.
  bool get hasNoAvailableArtists {
    if (trackArtistNames.isEmpty) {
      return true;
    }
    if (trackArtistNames.length == 1) {
      if (['', kUnknownArtist].contains(trackArtistNames.first)) {
        return true;
      }
    }
    return false;
  }

  /// Whether the [Track] actually has meaningful actual album artists from metadata tags.
  bool get hasNoAvailableAlbumArtists =>
      ['', kUnknownArtist].contains(albumArtistName);

  /// Whether the [Track] actually has meaningful actual album from metadata tags.
  bool get hasNoAvailableAlbum => ['', kUnknownAlbum].contains(albumName);

  String get lyricsQuery => [
        trackName,
        !hasNoAvailableArtists
            ? trackArtistNames.take(2).join(' ')
            : !hasNoAvailableAlbumArtists
                ? albumArtistName
                : !hasNoAvailableAlbum
                    ? albumName
                    : '',
      ].join(' ').replaceAll(RegExp(r'[\\/:*?""<>|]'), ' ');
}

extension AndroidMediaFormatExtension on AndroidMediaFormat {
  String get label => [
        if (extension != null)
          if (kSupportedFileTypes.contains(extension!.toUpperCase()))
            extension!.toUpperCase(),
        if (bitrate != null && bitrate != 0.0) '${bitrate! ~/ 1000} kb/s',
        if (sampleRate != null)
          '${(sampleRate! / 1000).toStringAsFixed(1)} kHz',
        if (channelCount != null)
          if (channelCount == 1)
            'Mono'
          else if (channelCount == 2)
            'Stereo'
          else
            '$channelCount Channels',
      ].join(' • ');
}

extension PlaybackExtension on Playback {
  String get audioFormatLabel {
    if (index < 0 || index >= tracks.length) return '';
    if (!tracks[index].uri.isScheme('FILE')) return '';
    final data = [
      if (audioBitrate != null && audioBitrate != 0.0)
        '${audioBitrate! ~/ 1000} kb/s',
      if (audioParams.sampleRate != null)
        '${(audioParams.sampleRate! / 1000).toStringAsFixed(1)} kHz',
      if (audioParams.channelCount != null)
        if (audioParams.channelCount == 1)
          'Mono'
        else if (audioParams.channelCount == 2)
          'Stereo'
        else
          '${audioParams.channelCount} Channels',
    ];
    try {
      final ext = File(tracks[index].uri.toFilePath()).extension;
      if (data.join().trim().isNotEmpty && kSupportedFileTypes.contains(ext)) {
        data.insert(
          0,
          ext,
        );
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    return data.join(' • ');
  }

  String get audioFormatLabelSmall {
    if (index < 0 || index >= tracks.length) return '';
    if (!tracks[index].uri.isScheme('FILE')) return '';
    final data = [
      if (audioBitrate != null && audioBitrate != 0.0)
        '${audioBitrate! ~/ 1000} kb/s',
      if (audioParams.sampleRate != null)
        '${(audioParams.sampleRate! / 1000).toStringAsFixed(1)} kHz',
    ];
    try {
      final ext = File(tracks[index].uri.toFilePath()).extension;
      if (data.join().trim().isNotEmpty && kSupportedFileTypes.contains(ext)) {
        data.insert(
          0,
          ext,
        );
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
    return data.join(' • ');
  }
}
