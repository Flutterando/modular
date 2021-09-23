import 'package:flutter_modular/src/presenter/models/module.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';
import 'package:flutter_modular/src/domain/services/bind_service.dart';
import 'package:flutter_modular/src/domain/services/module_service.dart';
import 'package:flutter_modular/src/domain/services/route_service.dart';

class BindServiceMock extends Mock implements BindService {}

class RouteServiceMock extends Mock implements RouteService {}

class ModuleMock extends Mock implements Module {}

class ModuleServiceMock extends Mock implements ModuleService {}

class RouteContextMock extends Mock implements RouteContext {}

class ModularRouteMock extends Mock implements ModularRoute {}

class InjectorMock extends Mock implements Injector {}

class TrackerMock extends Mock implements Tracker {}
