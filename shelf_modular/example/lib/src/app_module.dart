import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'auth/auth_module.dart';
import 'auth/presenter/guards/auth_guard.dart';
import 'auth/presenter/websocket/chat_websocket.dart';

class AppModule extends Module {
  @override
  void routes(r) {
    r.get('/', (Request request) => Response.ok('ok!!'));
    r.get('/2', (Request request) => Response.ok('ok!!'),
        middlewares: [AuthGuard3()]);
    r.module('/auth', module: AuthModule());
    r.websocket('/websocket', websocket: ChatWebSocket());
  }
}
