import 'package:flutter/foundation.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GuardT extends RouteGuard {
  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    debugPrint(Modular.args.toString());
    return true;
  }
}
