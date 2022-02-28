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
