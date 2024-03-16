/// Extensions for [Duration].
extension DurationExtension on Duration {
  /// Format [Duration] as `DDD:HH:MM:SS`, `HH:MM:SS` or `MM:SS`.
  String get label {
    final days = inDays.toString().padLeft(3, '0');
    final hours = (inHours - (inDays * 24)).toString().padLeft(2, '0');
    final minutes = (inMinutes - (inHours * 60)).toString().padLeft(2, '0');
    final seconds = (inSeconds - (inMinutes * 60)).toString().padLeft(2, '0');
    if (this > const Duration(days: 1)) {
      return '$days:$hours:$minutes:$seconds';
    } else if (this > const Duration(hours: 1)) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
}
