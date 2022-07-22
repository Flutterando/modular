import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'auth/auth_module.dart';
import 'auth/presenter/guards/auth_guard.dart';
import 'auth/presenter/websocket/chat_websocket.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  final List<ModularRoute> routes = [
    Route.get('/', (Request request) => Response.ok('ok!!')),
    Route.get('/2', (Request request) => Response.ok('ok!!'),
        middlewares: [AuthGuard3()]),
    Route.module('/auth', module: AuthModule()),
    Route.websocket('/websocket', websocket: ChatWebSocket()),
  ];
}
