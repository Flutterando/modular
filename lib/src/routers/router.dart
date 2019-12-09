import 'package:flutter/widgets.dart';
import 'package:flutter_modular/src/interfaces/child_module.dart';

class Router {
  final String routerName;

  final Widget Function(BuildContext context, dynamic args) child;
  final ChildModule module;
  String moduleName;

  Router(this.routerName, {this.module, this.child});
}
