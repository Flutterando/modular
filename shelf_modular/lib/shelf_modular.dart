library dart_modular;

import 'package:shelf_modular/src/shelf_modular_module.dart';

import 'src/presenter/modular_base.dart';

export 'package:modular_core/modular_core.dart'
    show
        ModularRoute,
        Disposable,
        Module,
        BindConfig,
        Injector,
        AutoInjectorException,
        ModularArguments,
        RouteManager,
        setPrintResolver;

export 'src/presenter/extensions/route_manage_extension.dart';
export 'src/presenter/middlewares/middlewares.dart';
export 'src/presenter/models/route.dart';
export 'src/presenter/resources/resource.dart';
export 'src/presenter/resources/websocket_resource.dart';

IModularBase? _modular;

/// Instance of Modular for search binds and route.
// ignore: non_constant_identifier_names
IModularBase get Modular {
  _modular ??= injector.get<IModularBase>();
  return _modular!;
}
