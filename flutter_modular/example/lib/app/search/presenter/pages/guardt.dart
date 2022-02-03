import 'package:flutter_modular/flutter_modular.dart';

class GuardT extends RouteGuard {
  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    print(Modular.args);
    return true;
  }
}
