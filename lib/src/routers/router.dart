import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/interfaces/child_module.dart';
import 'package:flutter_modular/src/interfaces/route_guard.dart';

class Router {
  final String routerName;

  final Widget Function(BuildContext context, ModularArguments args) child;
  final ChildModule module;
  Map<String, dynamic> params;
  final List<RouteGuard> guards;

  Router(this.routerName, {this.module, this.child, this.guards});
}
