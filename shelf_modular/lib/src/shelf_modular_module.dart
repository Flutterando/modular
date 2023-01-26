import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/usecases/report_push.dart';

import 'domain/services/bind_service.dart';
import 'domain/services/module_service.dart';
import 'domain/services/route_service.dart';
import 'domain/usecases/dispose_bind.dart';
import 'domain/usecases/finish_module.dart';
import 'domain/usecases/get_arguments.dart';
import 'domain/usecases/get_bind.dart';
import 'domain/usecases/get_route.dart';
import 'domain/usecases/start_module.dart';
import 'infra/services/bind_service_impl.dart';
import 'infra/services/module_service_impl.dart';
import 'infra/services/route_service_impl.dart';
import 'presenter/modular_base.dart';

final _innerInjector = AutoInjector(
  tag: 'ModularApp',
  on: (i) {
    i.addInstance(i);
    i.commit();
  },
);

final injector = AutoInjector(
  tag: 'ModularCore',
  on: (i) {
    i.add<Tracker>(Tracker.new);
    i.add<AutoInjector>(_innerInjector);
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
    i.add<ReportPush>(ReportPushImpl.new);
    //presenter
    i.addSingleton<IModularBase>(ModularBase.new);
    i.commit();
  },
);
