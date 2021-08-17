library dart_modular;

import 'package:dart_modular/src/route.dart';
import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart';

Handler ModularApp({required Module module}) {
  Tracker.runApp(module);
  return (Request request) async {
    final uri = request.url.replace(path: '/${request.url.path}@${request.method}');
    final route = await Tracker.findRoute(uri.toString()) as Route?;
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
  };
}

class TestModule extends Module {
  @override
  List<ModularRoute> get routes => [
        Route.get('/', (Request request, ModularArguments arg) => Response.ok('modular get ${arg.queryParams['q'] ?? ''}')),
        Route.get('/:name', (Request request, ModularArguments arg) => Response.ok('modular get wirh params ${arg.params['name']}')),
        Route.post('/', (Request request) => Response.ok('modular post')),
        Route.delete('/', (Request request) => Response.ok('modular delete')),
        Route.put('/', (Request request) => Response.ok('modular put')),
        Route.path('/', (Request request) => Response.ok('modular path')),
      ];
}
