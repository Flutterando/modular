import 'bind.dart';

abstract class BindContext {
  List<Bind> get binds;
  List<BindContext> get imports;

  T? getBind<T extends Object>();

  /// Dispose bind from the memory
  bool remove<T>();

  /// Dispose all bind from the memory
  void dispose();
}
