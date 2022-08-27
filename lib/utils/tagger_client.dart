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
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

/// TaggerClient
/// ------------
///
/// **Spoilers:**
///
/// Without any second thought, this is a glue.
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
  static String? _dll;

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
    assert(executable.startsWith('/') && !executable.endsWith('/'));
    final script = '''if [[ -f "$executable" && -x "$executable" ]]; then
  echo "true"
else
  echo "false"
fi
''';
    final permission = await Process.run(
      'bash',
      [
        '-c',
        script,
      ],
      runInShell: true,
    );
    if (permission.stdout.toString().trim() != 'true' ||
        permission.stderr.toString().isNotEmpty) {
      final chmod = await Process.run(
        'chmod',
        [
          '+x',
          executable,
        ],
        runInShell: true,
      );
      if (chmod.exitCode != 0) {
        debugPrint(chmod.stdout.toString());
        debugPrint(chmod.stderr.toString());
        throw TaggerClientPermissionRequestException(
          [
            if (chmod.stdout.toString().isNotEmpty) chmod.stdout.toString(),
            if (chmod.stderr.toString().isNotEmpty) chmod.stderr.toString(),
          ].join(),
        );
      }
    }
    _executable ??= executable;
    _dll ??= dynamicLibrary;
  }

  TaggerClient({
    this.verbose = false,
  }) {
    assert(
      _executable != null,
      '[TaggerClient.ensureInitialized] is not called.',
    );
    Process.start(
      _executable!,
      [
        if (verbose) '--verbose',
        if (_dll != null) _dll!,
      ],
      runInShell: true,
    ).then(
      (process) {
        this.process.complete(process);
        process.stdout.listen(stdout);
      },
    );
  }

  void stdout(List<int> buffer) {
    try {
      metadata.complete(
        Map<String, String>.from(
          json.decode(
            utf8.decode(buffer),
          ),
        ),
      );
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
      try {
        metadata.completeError(
          FormatException(
            utf8.decode(buffer),
          ),
        );
      } catch (exception, stacktrace) {
        // Just to prevent any possible dead-locks.
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
        metadata.completeError(FormatException());
      }
    }
  }

  Future<Map<String, String>> parse(
    String media, {
    File? cover,
    Directory? coverDirectory,
    bool duration = false,
    bool bitrate = false,
    Duration timeout = const Duration(seconds: 5),
  }) {
    return lock.synchronized<Map<String, String>>(
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

  /// Whether background [Process] has been terminated using [dispose].
  bool running = true;

  /// Background `tagger` [Process].
  Completer<Process> process = Completer<Process>();

  /// Used for catching metadata from
  Completer<Map<String, String>> metadata = Completer<Map<String, String>>();

  /// Whether to request `bitrate` & `duration` in metadata response.
  final bool verbose;

  /// Used for ensuring mutual exclusion in [parse].
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
