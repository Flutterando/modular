import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'app_resource.dart';

class AppModule extends Module {
  @override
  List<Module> get imports => [];

  @override
  List<Bind> get binds => [
        Bind.scoped((i) => Controller()),
      ];

  @override
  List<ModularRoute> get routes => [
        Route.post('/', () => Response.ok('OI kiringa')),
        Route.resource('/resource', resource: AppResource()),
      ];
}
