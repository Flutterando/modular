library dart_modular;

import 'package:shelf_modular/src/shelf_modular_module.dart';

import 'src/presenter/modular_base.dart';

export 'package:modular_core/modular_core.dart' show ModularRoute, Disposable, Module, Bind, AutoBind, AutoInjector, AutoInjectorException, ModularArguments;

export 'src/presenter/middlewares/middlewares.dart';
export 'src/presenter/models/route.dart';
export 'src/presenter/resources/resource.dart';
export 'src/presenter/resources/websocket_resource.dart';

// ignore: non_constant_identifier_names
final Modular = injector<IModularBase>();
