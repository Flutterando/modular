import 'package:shelf_modular/shelf_modular.dart';

class ChatWebSocket extends WebSocketResource {
  @override
  void connect(socket) {
    socket.emit('SERVIDOR: Novo cliente conectado!');
  }

  @override
  void onMessage(covariant String data, socket) {
    if (data.startsWith('@enterroom ')) {
      final room = data.replaceFirst('@enterroom ', '');
      socket.joinRoom(room);
      socket.sink.add('Você entrou na sala $room');
      socket.emit('ROOM: Novo cliente conectado', [room]);
    } else if (data.startsWith('@leaveroom ')) {
      final room = data.replaceFirst('@leaveroom ', '');
      socket.sink.add('Você saiu na sala $room');
      socket.leaveRoom(room);
      socket.emit('ROOM: Cliente saiu da sala', [room]);
    } else if (data.startsWith('@changename ')) {
      final name = data.replaceFirst('@changename ', '');
      socket.emitToRooms('${socket.tag} trocou o nome para $name');
      socket.sink.add('Agora seu nome é $name');
      socket.tag = name;
    } else if (socket.enteredRooms.isNotEmpty) {
      socket.emitToRooms('${socket.tag}: $data');
    } else {
      socket.sink.add('Entre em uma sala pra tc');
    }
  }

  @override
  void disconnect(socket) {
    socket.emit('SERVIDOR: Cliente desconectado');
  }
}
