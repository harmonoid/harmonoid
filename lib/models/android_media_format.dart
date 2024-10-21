/// {@template android_media_format}
///
/// AndroidMediaFormat
/// ------------------
///
/// {@endtemplate}
class AndroidMediaFormat {
  /// Bitrate.
  final int? bitrate;

  /// Sample rate.
  final int? sampleRate;

  /// Channel count.
  final int? channelCount;

  /// Extension.
  final String? extension;

  /// {@macro android_media_format}
  const AndroidMediaFormat({
    this.bitrate,
    this.sampleRate,
    this.channelCount,
    this.extension,
  });

  AndroidMediaFormat copyWith({
    int? bitrate,
    int? sampleRate,
    int? channelCount,
    String? extension,
  }) {
    return AndroidMediaFormat(
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      channelCount: channelCount ?? this.channelCount,
      extension: extension ?? this.extension,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AndroidMediaFormat &&
          runtimeType == other.runtimeType &&
          bitrate == other.bitrate &&
          sampleRate == other.sampleRate &&
          channelCount == other.channelCount &&
          extension == other.extension;

  @override
  int get hashCode => Object.hash(
        bitrate,
        sampleRate,
        channelCount,
        extension,
      );

  @override
  String toString() => 'AndroidMediaFormat('
      'bitrate: $bitrate, '
      'sampleRate: $sampleRate, '
      'channelCount: $channelCount, '
      'extension: $extension'
      ')';
}
