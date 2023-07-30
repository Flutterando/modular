import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular/src/domain/services/bind_service.dart';
import 'package:shelf_modular/src/domain/services/module_service.dart';
import 'package:shelf_modular/src/domain/services/route_service.dart';
import 'package:shelf_modular/src/domain/usecases/dispose_bind.dart';
import 'package:shelf_modular/src/domain/usecases/finish_module.dart';
import 'package:shelf_modular/src/domain/usecases/get_arguments.dart';
import 'package:shelf_modular/src/domain/usecases/get_bind.dart';
import 'package:shelf_modular/src/domain/usecases/get_route.dart';
import 'package:shelf_modular/src/domain/usecases/report_push.dart';
import 'package:shelf_modular/src/domain/usecases/start_module.dart';

class BindServiceMock extends Mock implements BindService {}

class RouteServiceMock extends Mock implements RouteService {}

class ModuleServiceMock extends Mock implements ModuleService {}

class ModuleMock extends Mock implements Module {}

class ModularRouteMock extends Mock implements ModularRoute {}

class InjectorMock extends Mock implements AutoInjector {}

class TrackerMock extends Mock implements Tracker {}

class DisposeBindMock extends Mock implements DisposeBind {}

class GetArgumentsMock extends Mock implements GetArguments {}

class FinishModuleMock extends Mock implements FinishModule {}

class GetBindMock extends Mock implements GetBind {}

class StartModuleMock extends Mock implements StartModule {}

class GetRouteMock extends Mock implements GetRoute {}

class RequestMock extends Mock implements Request {}

class RouteMock extends Mock implements Route {}

class DisposableMock extends Mock implements Disposable {}

class ReportPushMock extends Mock implements ReportPush {}
