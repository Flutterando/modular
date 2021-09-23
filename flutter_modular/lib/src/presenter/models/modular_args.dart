/// Flags can change Modular behavior.
/// [isDebug] = Enables text printing for debugging.
/// [isCupertino] = Works with Cupertino-style routes.
/// [experimentalNotAllowedParentBinds] = Prohibits taking any bind of parent modules,
/// forcing the imports of the same in the current module to be accessed.
/// This is the same behavior as the system.
class ModularFlags {
  /// Prohibits taking any bind of parent modules,
  /// forcing the imports of the same in the current module to be accessed.
  /// This is the same behavior as the system.
  /// Default is false;
  bool experimentalNotAllowedParentBinds;

  /// Works with Cupertino-style routes.
  /// Default is false;
  bool isCupertino;

  /// Enables text printing for debugging.
  /// Default is true;
  bool isDebug;
  ModularFlags({
    this.experimentalNotAllowedParentBinds = false,
    this.isCupertino = false,
    this.isDebug = true,
  });
}
