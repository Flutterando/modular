import 'bind.dart';
import 'injector.dart';

abstract class BindContext {
  /// Vincular objetos de injeção
  List<BindContract> get binds;

  /// Import Binds from other modules.
  /// ATTENTION: The binds must be marked with the flag export: true, in the module to be imported.
  List<BindContext> get imports;

  /// Pega os binds referente a esse contexto.
  T? getBind<T extends Object>(Injector injector);

  /// Dispose bind from the memory
  bool remove<T>();

  /// Dispose all bind from the memory
  void dispose();

  /// checks if all asynchronous binds are ready to be used synchronously.
  Future<void> isReady();
}
