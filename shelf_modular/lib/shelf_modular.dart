library dart_modular;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf_modular/src/route.dart';
import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart';
import 'src/request_extension.dart';
export 'src/request_extension.dart';

Handler ModularApp({required Module module}) {
  Tracker.runApp(module);
  return _handler;
}

FutureOr<Response> _handler(Request request) async {
  final data = await tryJsonDecode(request);
  final route = await Tracker.findRoute('/${request.url.toString()}', schema: request.method, data: data ?? {}) as Route?;
  if (route != null) {
    final handler = route.handler;
    if (handler is Handler) {
      return handler(request);
    } else if (handler is HandlerWithArgs) {
      return handler(request, Tracker.arguments);
    } else {
      throw 'Handler not correct';
    }
  }
  return Response.notFound('');
}

Future<Map?> tryJsonDecode(Request request) async {
  if (request.method == 'GET') return null;
  print(request.isMultipart);

  if (!request.isMultipart) {
    try {
      final data = await request.readAsString();
      return jsonDecode(data);
    } on FormatException catch (e) {
      if (e.message == 'Unexpected extension byte') {
      } else if (e.message == 'Missing expected digit') {}
      return null;
    }
  }

  await for (final part in request.parts) {
    var header = HeaderValue.parse(request.headers['content-type']!);
    if (part.headers.containsKey('content-disposition')) {
      header = HeaderValue.parse(part.headers['content-disposition']!);
      var filename = header.parameters['filename']!;
      final file = File(filename);
      final fileSink = file.openWrite();
      await part.pipe(fileSink);
      await fileSink.close();
    }
  }
}

class TestModule extends Module {
  @override
  List<ModularRoute> get routes => [
        Route.get('/', (Request request, ModularArguments arg) => Response.ok('modular get ${arg.queryParams['q'] ?? ''}')),
        Route.get('/:name', (Request request, ModularArguments arg) => Response.ok('modular get wirh params ${arg.params['name']}')),
        Route.post('/', (Request request, ModularArguments arg) => Response.ok('modular post ${arg.data?['name']}')),
        Route.delete('/', (Request request) => Response.ok('modular delete')),
        Route.put('/', (Request request) => Response.ok('modular put')),
        Route.path('/', (Request request) => Response.ok('modular path')),
      ];
}
