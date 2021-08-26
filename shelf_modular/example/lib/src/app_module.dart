import 'package:shelf_modular/shelf_modular.dart';

import 'auth/auth_module.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
        Route.module('/auth', module: AuthModule()),
      ];
}
