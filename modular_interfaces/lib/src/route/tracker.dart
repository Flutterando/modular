import 'dart:async';

import 'package:modular_interfaces/modular_interfaces.dart';

import 'modular_arguments.dart';

abstract class Tracker {
  final Injector injector;
  RouteContext get module;

  Tracker(this.injector);

  var arguments = ModularArguments.empty();

  String get currentPath => arguments.uri.toString();

  FutureOr<ModularRoute?> findRoute(String path, {dynamic data, String schema = ''});

  void reportPopRoute(ModularRoute route);

  void runApp(RouteContext module);

  void finishApp();
}
