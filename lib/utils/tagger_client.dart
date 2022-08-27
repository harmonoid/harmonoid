/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Yehuda Kremer <yehudakremer@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';

/// TaggerClient
/// ------------
///
/// **Problem:**
///
/// Apparently using [Tagger] directly on Linux systems results in a memory leak.
/// In so far study, I haven't been able to find it's cause.
/// As long as Flutter engine & libmpv stay under the same process, the memory
/// leaks when reading metadata of large number of media [File]s.
///
/// **Solution:**
///
/// This class internally invokes a separately compiled & shipped executable (
/// along-side Harmonoid, also written in `dart-lang`) using [Process.start] and
/// retrieves metadata of media [File]s.
///
/// The mentioned executable binary is present at `./assets/platform/tagger`.
/// This is only bundled when compiled for Linux.
///
/// The API of this class is completely inspired & same as [Tagger] from
/// `package:libmpv`. This has been done for obvious reasons.
///
/// [ensureInitialized] must be called on supported platforms (i.e. Linux) before
/// [runApp] from Flutter.
///
class TaggerClient {
  /// Absolute path to the `tagger` executable.
  static String? _executable;

  /// Custom path to the `libmpv.so` optionally passed by the user.
  static String? _dynamicLibrary;

  /// Initializes [TaggerClient] class for usage.
  static Future<void> ensureInitialized({
    String? dynamicLibrary,
  }) async {
    if (_executable != null) {
      return;
    }
    final dir = File(Platform.resolvedExecutable).parent.path;
    final executable = join(
      dir,
      'data',
      'flutter_assets',
      'assets',
      'platform',
      'tagger',
    );
    assert(Platform.isLinux);
    assert(dir.startsWith('/'));
    final chmod = await Process.run(
      'chmod',
      [
        '+x',
        executable,
      ],
      runInShell: true,
    );
    if (chmod.exitCode != 0) {
      throw TaggerClientPermissionRequestException(
        '${chmod.stdout}\n${chmod.stderr}\n${chmod.exitCode}',
      );
    }
    final executableVersion = await Process.run(
      executable,
      [
        '--version',
      ],
      runInShell: true,
    );
    if (executableVersion.exitCode != 0 ||
        executableVersion.stderr.toString().isNotEmpty ||
        !executableVersion.stdout.toString().startsWith('Tagger')) {
      throw TaggerClientVerificationException(
        '${chmod.stdout}\n${chmod.stderr}\n${chmod.exitCode}',
      );
    }
    _executable ??= executable;
    _dynamicLibrary ??= dynamicLibrary;
  }

  TaggerClient({this.verbose = false});

  void listener(List<int> buffer) {
    metadata.complete(
      Map<String, String>.from(
        json.decode(
          utf8.decode(buffer),
        ),
      ),
    );
  }

  Future<Map<String, String>> parse(
    String media, {
    File? cover,
    Directory? coverDirectory,
    bool duration = false,
    bool bitrate = false,
    Duration timeout = const Duration(seconds: 5),
  }) {
    return lock.synchronized(
      () async {
        assert(running);
        final process = await this.process.future;
        metadata = Completer();
        process.stdin
          ..writeln('parse')
          ..writeln(media)
          ..writeln(cover?.path ?? '')
          ..writeln(coverDirectory?.path ?? '')
          ..writeln(timeout.inMilliseconds);
        return metadata.future;
      },
    );
  }

  Future<void> dispose() async {
    assert(running);
    running = false;
    final process = await this.process.future;
    process.stdin.writeln('dispose');
  }

  bool running = true;
  Completer<Process> process = Completer<Process>();
  Completer<Map<String, String>> metadata = Completer<Map<String, String>>();

  final bool verbose;
  final lock = Lock();
}

/// A generic exception related to [TaggerClient].
///
/// Specify [message] to describe the details.
///
class TaggerClientException implements Exception {
  final String message;

  TaggerClientException(this.message);

  @override
  String toString() => 'TaggerClientException: $message';
}

/// Exception raised when `tagger` binary could not be marked as an executable
/// using `chmod` command on Linux.
///
class TaggerClientPermissionRequestException extends TaggerClientException {
  TaggerClientPermissionRequestException(super.message);

  @override
  String toString() => 'TaggerClientPermissionRequestException: $message';
}

/// Exception raised when `tagger` binary could not verified.
///
class TaggerClientVerificationException extends TaggerClientException {
  TaggerClientVerificationException(super.message);

  @override
  String toString() => 'TaggerClientVerificationException: $message';
}
