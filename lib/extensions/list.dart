/// Extensions for [List].
extension ListExtensions<T> on List<T> {
  /// Returns alternate list if the list is empty.
  List<T> ifEmpty(List<T> alternate) {
    return isEmpty ? alternate : this;
  }
}
