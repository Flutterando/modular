import 'package:flutter_modular/flutter_modular.dart';

class GuardT extends RouteGuard {
  final String guardedRoute;
  GuardT(this.guardedRoute) : super();

  @override
  Future<bool> canActivate(String path, ModularRoute router) async {
    print(Modular.args);
    return true;
  }
}
