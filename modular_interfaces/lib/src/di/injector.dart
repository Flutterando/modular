import 'bind_context.dart';

/// Service injector that is responsible for searching for instances in all bind contexts.
abstract class Injector<T> {
  B call<B extends Object>() => get<B>();

  /// Request an instance by [Type]
  B get<B extends Object>();

  /// Checks if the context (Module) is in the context of binds.
  bool isModuleAlive<T extends BindContext>();

  /// adds a context to the tree.
  void addBindContext(BindContext module, {String tag = ''});

  /// Removes a [BindContext] based on its tags.
  /// If your tag repository is empty, the BindContext will be removed automatically.
  void disposeModuleByTag(String tag);

  /// Removes only ScopedBind from BindContext tree
  void removeScopedBinds();

  /// Dispose a [Bind] by [Type]
  bool dispose<B extends Object>();

  /// Destroy all BindContext
  void destroy();

  /// remove [BindContext] by [Type]
  void removeBindContext<T extends BindContext>();

  /// checks if all asynchronous binds are ready to be used synchronously of all BindContext of Tree.
  Future<bool> isModuleReady<M extends BindContext>();

  /// used for reassemble all singleton injections
  void reassemble();

  /// internal
  /// used for reassemble bind list
  void updateBinds(BindContext context);
}
