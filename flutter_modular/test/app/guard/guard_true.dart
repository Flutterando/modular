import 'package:flutter_modular/src/interfaces/route_guard.dart';

class MyGuardTrue implements RouteGuard {
  @override
  bool canActivate(String url) {
    return true;
  }

  @override
  List<GuardExecutor> get executors => [];
}
