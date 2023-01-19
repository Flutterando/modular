import 'dart:async';

import 'package:modular_interfaces/modular_interfaces.dart';

abstract class Tracker {
  /// Service Injector instancia
  final Injector injector;

  /// Initial Module
  RouteContext get module;

  Tracker(this.injector);

  ModularArguments get arguments;

  void setArguments(ModularArguments arguments);

  String get currentPath => arguments.uri.toString();

  /// Searches for a route by name or context throughout the tree.
  FutureOr<ModularRoute?> findRoute(String path,
      {dynamic data, String schema = ''});

  /// Reports whether a route will leave the route context. This is important to call automatic dispose of the entire context.
  void reportPopRoute(ModularRoute route);

  /// It informs you that a new route has been found and that it needs its dependent BindContexts started as well.
  void reportPushRoute(ModularRoute route);

  /// Responsible for starting the app.
  /// It should only be called once, but it should be the first method to be called before a route or bind lookup.
  void runApp(RouteContext module);

  /// Finishes all trees.
  void finishApp();

  /// used for reassemble all routes
  void reassemble();
}
