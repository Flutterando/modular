import 'dart:io';

import 'package:dart_modular/dart_modular.dart';

import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_hotreload/shelf_hotreload.dart';

void main() async {
  withHotreload(() => createServer());
}

Future<HttpServer> createServer() async {
  print('Serving at http://localhost:8080');

  return io.serve(ModularApp(module: TestModule()), 'localhost', 8080);
}
