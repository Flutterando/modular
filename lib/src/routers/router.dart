import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/interfaces/child_module.dart';

class Router {
  final String routerName;

  final Widget Function(BuildContext context, ModularArguments args) child;
  final ChildModule module;
  Map<String, dynamic> params;

  Router(this.routerName, {this.module, this.child});
}
