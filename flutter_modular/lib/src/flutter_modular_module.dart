import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/src/domain/usecases/bind_module.dart';
import 'package:flutter_modular/src/domain/usecases/report_pop.dart';
import 'package:flutter_modular/src/domain/usecases/report_push.dart';
import 'package:modular_core/modular_core.dart';

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
import 'domain/usecases/set_arguments.dart';
import 'domain/usecases/start_module.dart';
import 'domain/usecases/unbind_module.dart';
import 'infra/services/bind_service_impl.dart';
import 'infra/services/module_service_impl.dart';
import 'infra/services/route_service_impl.dart';
import 'presenter/models/bind.dart';
import 'presenter/models/module.dart';
import 'presenter/modular_base.dart';
import 'presenter/navigation/modular_route_information_parser.dart';
import 'presenter/navigation/modular_router_delegate.dart';

final injector = InjectorImpl()..addBindContext(FlutterModularModule());

class FlutterModularModule extends Module {
  @override
  List<Bind> get binds => [
        //datasource
        Bind.instance<Tracker>(ModularTracker),
        Bind.instance<Injector>(ModularTracker.injector),
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
        Bind.factory<BindModule>((i) => BindModuleImpl(i())),
        Bind.factory<ReportPop>((i) => ReportPopImpl(i())),
        Bind.factory<SetArguments>((i) => SetArgumentsImpl(i())),
        Bind.factory<UnbindModule>((i) => UnbindModuleImpl(i())),
        Bind.factory<ReportPush>((i) => ReportPushImpl(i())),
        //presenter
        Bind.singleton<ModularRouteInformationParser>((i) =>
            ModularRouteInformationParser(
                getRoute: i(),
                getArguments: i(),
                setArguments: i(),
                reportPush: i())),
        Bind.singleton<ModularRouterDelegate>((i) => ModularRouterDelegate(
            parser: i(),
            navigatorKey: GlobalKey<NavigatorState>(),
            reportPop: i())),
        Bind.singleton<IModularBase>((i) => ModularBase(
            disposeBind: i(),
            finishModule: i(),
            getBind: i(),
            isModuleReadyUsecase: i(),
            navigator: i(),
            startModule: i(),
            getArguments: i())),
      ];
}
