/// Extensions for [DateTime].
extension DateTimeExtensions on DateTime {
  /// Format [DateTime] as `DD-MM-YYYY`.
  String get label => '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
}
