import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/usecases/reassemble_tracker.dart';
import 'package:shelf_modular/src/domain/usecases/report_push.dart';

import 'domain/services/bind_service.dart';
import 'domain/services/module_service.dart';
import 'domain/services/route_service.dart';
import 'domain/usecases/dispose_bind.dart';
import 'domain/usecases/finish_module.dart';
import 'domain/usecases/get_arguments.dart';
import 'domain/usecases/get_bind.dart';
import 'domain/usecases/get_route.dart';
import 'domain/usecases/module_ready.dart';
import 'domain/usecases/release_scoped_binds.dart';
import 'domain/usecases/start_module.dart';
import 'infra/services/bind_service_impl.dart';
import 'infra/services/module_service_impl.dart';
import 'infra/services/route_service_impl.dart';
import 'presenter/models/bind.dart';
import 'presenter/models/module.dart';
import 'presenter/modular_base.dart';

final injector = InjectorImpl()..addBindContext(ShelfModularModule());

class ShelfModularModule extends Module {
  @override
  List<Bind> get binds => [
        //datasource
        Bind.factory<Tracker>((i) => modularTracker),
        Bind.factory<Injector>((i) => modularTracker.injector),
        //infra
        Bind.factory<BindService>((i) => BindServiceImpl(i())),
        Bind.factory<ModuleService>((i) => ModuleServiceImpl(i())),
        Bind.factory<RouteService>((i) => RouteServiceImpl(i())),
        //domain
        Bind.factory<DisposeBind>((i) => DisposeBindImpl(i())),
        Bind.factory<FinishModule>((i) => FinishModuleImpl(i())),
        Bind.factory<GetBind>((i) => GetBindImpl(i())),
        Bind.factory<GetRoute>((i) => GetRouteImpl(i())),
        Bind.factory<StartModule>((i) => StartModuleImpl(i())),
        Bind.factory<IsModuleReady>((i) => IsModuleReadyImpl(i())),
        Bind.factory<GetArguments>((i) => GetArgumentsImpl(i())),
        Bind.factory<ReleaseScopedBinds>((i) => ReleaseScopedBindsImpl(i())),
        Bind.factory<ReportPush>((i) => ReportPushImpl(i())),
        Bind.factory<ReassembleTracker>((i) => ReassembleTrackerImpl(i())),
        //presenter
        Bind.singleton<IModularBase>((i) =>
            ModularBase(i(), i(), i(), i(), i(), i(), i(), i(), i(), i())),
      ];
}
