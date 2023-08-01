import 'package:flutter/material.dart';
import 'package:flutter_modular/src/domain/usecases/replace_instance.dart';
import 'package:modular_core/modular_core.dart';

import '../flutter_modular.dart';
import 'domain/services/bind_service.dart';
import 'domain/services/module_service.dart';
import 'domain/services/route_service.dart';
import 'domain/usecases/bind_module.dart';
import 'domain/usecases/dispose_bind.dart';
import 'domain/usecases/finish_module.dart';
import 'domain/usecases/get_arguments.dart';
import 'domain/usecases/get_bind.dart';
import 'domain/usecases/get_route.dart';
import 'domain/usecases/report_pop.dart';
import 'domain/usecases/report_push.dart';
import 'domain/usecases/set_arguments.dart';
import 'domain/usecases/start_module.dart';
import 'domain/usecases/unbind_module.dart';
import 'infra/services/bind_service_impl.dart';
import 'infra/services/module_service_impl.dart';
import 'infra/services/route_service_impl.dart';
import 'presenter/modular_base.dart';
import 'presenter/navigation/modular_route_information_parser.dart';
import 'presenter/navigation/modular_router_delegate.dart';

final _innerInjector = AutoInjector(
  tag: 'ModularApp',
  on: (i) {
    i.addInstance<AutoInjector>(i);
    i.commit();
  },
);

final injector = AutoInjector(
  tag: 'ModularCore',
  on: (i) {
    //datasource
    i.addInstance<AutoInjector>(_innerInjector);
    i.addSingleton<Tracker>(Tracker.new);
    //infra
    i.add<BindService>(BindServiceImpl.new);
    i.add<ModuleService>(ModuleServiceImpl.new);
    i.add<RouteService>(RouteServiceImpl.new);
    //domain
    i.add<DisposeBind>(DisposeBindImpl.new);
    i.add<FinishModule>(FinishModuleImpl.new);
    i.add<GetBind>(GetBindImpl.new);
    i.add<GetRoute>(GetRouteImpl.new);
    i.add<StartModule>(StartModuleImpl.new);
    i.add<GetArguments>(GetArgumentsImpl.new);
    i.add<BindModule>(BindModuleImpl.new);
    i.add<ReportPop>(ReportPopImpl.new);
    i.add<SetArguments>(SetArgumentsImpl.new);
    i.add<UnbindModule>(UnbindModuleImpl.new);
    i.add<ReportPush>(ReportPushImpl.new);
    i.add<ReplaceInstance>(ReplaceInstanceImpl.new);
    //presenter
    i.addInstance(GlobalKey<NavigatorState>());
    i.addSingleton<ModularRouteInformationParser>(
      ModularRouteInformationParser.new,
    );
    i.addSingleton<ModularRouterDelegate>(ModularRouterDelegate.new);
    i.add<IModularNavigator>(() => i<ModularRouterDelegate>());
    i.addLazySingleton<IModularBase>(ModularBase.new);

    i.commit();
  },
);
