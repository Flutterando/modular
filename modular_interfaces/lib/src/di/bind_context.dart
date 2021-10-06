import 'bind.dart';
import 'injector.dart';

abstract class BindContext {
  /// Link injected objects
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

  /// get processed binds
  List<BindContract> getProcessBinds();

  /// Change binds
  void changeBinds(List<BindContract> newBinds);

  /// Bind ready as singleton
  List<SingletonBind> get instanciatedSingletons;
}
