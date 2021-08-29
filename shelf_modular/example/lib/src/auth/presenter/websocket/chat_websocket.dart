import 'package:shelf_modular/shelf_modular.dart';

class ChatWebSocket extends WebSocketResource {
  @override
  void connect(socket) {
    print('conectou');
  }

  @override
  void onMessage(data, socket) {
    print(data);
    socket.emit(data);
  }

  @override
  void disconnect(socket) {
    print('desconectou');
  }
}
