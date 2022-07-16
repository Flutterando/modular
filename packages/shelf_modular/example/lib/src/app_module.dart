import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'auth/auth_module.dart';
import 'auth/presenter/websocket/chat_websocket.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
        Route.get('/', (Request request) => Response.ok('ok')),
        Route.module('/auth', module: AuthModule()),
        Route.websocket('/websocket', websocket: ChatWebSocket()),
      ];
}
