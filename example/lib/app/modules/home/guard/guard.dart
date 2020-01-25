import 'package:flutter_modular/flutter_modular.dart';

class MyGuard implements RouteGuard {
  @override
  bool canActivate(String url) {
    return url != '/list/2';
  }
}
