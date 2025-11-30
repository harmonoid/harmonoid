/// Extensions for [Set].
extension SetExtensions<T> on Set<T> {
  /// Returns alternate list if the list is empty.
  Set<T> ifEmpty(Set<T> alternate) {
    return isEmpty ? alternate : this;
  }
}
