import 'bind.dart';
import 'injector.dart';

abstract class BindContext {
  List<Bind> get binds;
  List<BindContext> get imports;

  T? getBind<T extends Object>(Injector injector);

  /// Dispose bind from the memory
  bool remove<T>();

  /// Dispose all bind from the memory
  void dispose();

  Future<void> isReady();
}
