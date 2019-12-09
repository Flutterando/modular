import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

class Router {

  final String routerName;

  final Widget Function(BuildContext context, dynamic args) child;
  final CommonModule module;
  String moduleName;

  Router(this.routerName, {this.module, this.child});

}