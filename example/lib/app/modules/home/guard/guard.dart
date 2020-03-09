import 'package:flutter_modular/flutter_modular.dart';

class LoginExecutor extends GuardExecutor {
  final String message;
  LoginExecutor({this.message});

  @override
  onGuarded(String path, bool isActive) {
    if (isActive) {
      print('logined and pass');
      return;
    }

    print('toast: need login => $message');

    // Suppose login.
    Modular.to.pushNamed('/list/10');
  }
}

class MyGuard implements RouteGuard {
  @override
  bool canActivate(String url) {
    return url != '/list/2';
  }

  @override
  List<GuardExecutor> get executors => [LoginExecutor(message: 'List page')];
}
