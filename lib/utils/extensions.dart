extension ListExtension<T> on List<T> {
  /// Returns the first element that satisfies the test, or null if none found.
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}
