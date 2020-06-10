/// A class which implements [Disposable] can be disposed automatically
/// once user leaves a Module
abstract class Disposable {
  /// Disposes controllers, streams, etc.
  void dispose();
}
