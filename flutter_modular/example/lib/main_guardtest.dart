import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() => runApp(ModularApp(module: AppModule()));

class AppModule extends MainModule {
  @override
  List<Bind> get binds => [];

  @override
  Widget get bootstrap => MyApp();

  @override
  List<ModularRouter> get routers => [
        ModularRouter('/', module: HomeModule()),
        ModularRouter('/profile',
            module: ProfileModule(), guards: [AuthGuard()]),
      ];
}

class HomeModule extends ChildModule {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRouter> get routers => [
        ModularRouter('/', child: (_, __) => MyHomePage()),
      ];
}

class ProfileModule extends ChildModule {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRouter> get routers => [
        ModularRouter('/', child: (_, __) => ProfilePage()),
      ];
}

class AuthGuard extends RouteGuard {
  @override
  bool canActivate(String url) {
    return false;
  }

  @override
  List<GuardExecutor> get executors => [AuthExecutor()];
}

class AuthExecutor extends GuardExecutor {
  @override
  onGuarded(String path, {bool isActive}) {
    print(isActive);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //    navigatorKey: Modular.navigatorKey,
      initialRoute: '/',
      //    onGenerateRoute: Modular.generateRoute,
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Center(
        child: Icon(Icons.home, size: 64),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Modular.to.pushNamed('/profile');
        },
        label: Text("Entrar"),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logged In!"),
      ),
      body: Center(child: Icon(Icons.verified_user, size: 64)),
    );
  }
}
