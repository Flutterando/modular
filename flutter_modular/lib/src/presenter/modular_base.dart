import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/domain/usecases/bind_module.dart';
import 'package:flutter_modular/src/domain/usecases/replace_instance.dart';
import 'package:flutter_modular/src/domain/usecases/unbind_module.dart';
import 'package:modular_core/modular_core.dart';

import '../domain/usecases/dispose_bind.dart';
import '../domain/usecases/finish_module.dart';
import '../domain/usecases/get_arguments.dart';
import '../domain/usecases/get_bind.dart';
import '../domain/usecases/set_arguments.dart';
import '../domain/usecases/start_module.dart';
import 'errors/errors.dart';
import 'navigation/modular_route_information_parser.dart';
import 'navigation/modular_router_delegate.dart';

abstract class IModularBase {
  /// Finishes all trees(Modules).
  void destroy();

  // Responsible for starting the app.
  /// It should only be called once, but it should be the first
  /// method to be called before a route or bind lookup.
  void init(Module module);

  /// value is '/';
  String get initialRoute;

  /// Retrieves the ModularArguments instance.
  /// A ModularArguments is renewed every search for a new route.
  ModularArguments get args;

  /// Retrieves the IModularNavigator instance.
  /// By default the instance that controls all routes globally is returned,
  /// but this behavior can be replaced in ModularNavigator
  /// by a custom instance:
  ///
  /// Modular.navigatorDelegate = MyNavigatorDelegate();
  IModularNavigator get to;

  /// replaces the default ModularNavigator with a custom instance:
  /// Ideal for Unit Testing.
  /// Modular.navigatorDelegate = MyNavigatorDelegate()
  IModularNavigator? navigatorDelegate;

  /// Request an instance by [Type]
  B get<B extends Object>({String? key});

  /// Request an instance by [Type]
  /// <br>
  /// Return null if not found instance
  B? tryGet<B extends Object>({String? key});

  /// Dispose a bind by [Type]
  bool dispose<B extends Object>({String? key});

  /// Navigator 2.0 initializator: RouteInformationParser
  ModularRouteInformationParser get routeInformationParser;

  /// Navigator 2.0 initializator: RouterDelegate
  ModularRouterDelegate get routerDelegate;

  /// Navigator 2.0 initializator: RouterConfig
  RouterConfig<Object> get routerConfig;

  /// Change the starting route path
  void setInitialRoute(String initialRoute);

  /// Change a list of NavigatorObserver objects
  void setObservers(List<NavigatorObserver> navigatorObservers);

  /// Change the navigatorKey
  void setNavigatorKey(GlobalKey<NavigatorState>? key);

  /// Change the navigatorKey
  void setArguments(dynamic arguments);

  /// Change the navigatorKey
  void bindModule(Module module);

  /// remove all module binds by name
  void unbindModule<T extends Module>({String? type});

  /// replace instance
  void replaceInstance<T>(T instance, {String? key});

  @visibleForTesting
  String get initialRoutePath;
}

class ModularBase implements IModularBase {
  final DisposeBind disposeBind;
  final FinishModule finishModule;
  final GetBind getBind;
  final GetArguments getArguments;
  final SetArguments setArgumentsUsecase;
  final StartModule startModule;
  final BindModule bindModuleUsecase;
  final UnbindModule unbindModuleUsecase;
  final ReplaceInstance replaceInstanceUsecase;
  final IModularNavigator navigator;
  @override
  final ModularRouteInformationParser routeInformationParser;
  @override
  final ModularRouterDelegate routerDelegate;

  @override
  IModularNavigator? navigatorDelegate;

  bool _moduleHasBeenStarted = false;

  String _initialRoutePath = '/';

  @visibleForTesting
  @override
  String get initialRoutePath => _initialRoutePath;

  ModularBase(
    this.routeInformationParser,
    this.routerDelegate,
    this.disposeBind,
    this.getArguments,
    this.finishModule,
    this.getBind,
    this.startModule,
    this.navigator,
    this.setArgumentsUsecase,
    this.bindModuleUsecase,
    this.unbindModuleUsecase,
    this.replaceInstanceUsecase,
  );

  @override
  bool dispose<B extends Object>({String? key}) =>
      disposeBind<B>(key).getOrElse((left) => false);

  @override
  B get<B extends Object>({String? key}) {
    return getBind<B>(key).getOrThrow();
  }

  @override
  B? tryGet<B extends Object>({String? key}) {
    return getBind<B>(key).getOrNull();
  }

  @override
  void destroy() {
    _moduleHasBeenStarted = false;
    finishModule();
  }

  @override
  void init(Module module) {
    if (!_moduleHasBeenStarted) {
      startModule(module).getOrThrow();
      printResolverFunc?.call('${module.runtimeType} started!');
      _moduleHasBeenStarted = true;
    } else {
      throw ModuleStartedException(
        'Module ${module.runtimeType} is already started',
      );
    }
  }

  @override
  IModularNavigator get to => navigatorDelegate ?? navigator;

  @override
  ModularArguments get args =>
      getArguments().getOrElse((l) => ModularArguments.empty());

  final flags = ModularFlags();

  @override
  final String initialRoute = '/';

  @override
  void setInitialRoute(String value) {
    _initialRoutePath = value;
  }

  @override
  void setNavigatorKey(GlobalKey<NavigatorState>? key) {
    routerDelegate.setNavigatorKey(key);
  }

  @override
  void setObservers(List<NavigatorObserver> navigatorObservers) {
    routerDelegate.setObservers(navigatorObservers);
  }

  @override
  void setArguments(dynamic data) {
    setArgumentsUsecase.call(args.copyWith(data: data));
  }

  @override
  late final RouterConfig<Object> routerConfig = RouterConfig<Object>(
    routerDelegate: routerDelegate,
    routeInformationParser: routeInformationParser,
    routeInformationProvider: PlatformRouteInformationProvider(
      // ignore: deprecated_member_use
      initialRouteInformation: const RouteInformation(location: '/'),
    ),
    backButtonDispatcher: RootBackButtonDispatcher(),
  );

  @override
  void bindModule(Module module) {
    bindModuleUsecase(module).getOrThrow();
  }

  @override
  void unbindModule<T extends Module>({String? type}) {
    unbindModuleUsecase.call<T>(type: type).getOrThrow();
  }

  @override
  void replaceInstance<T>(T instance, {String? key}) {
    replaceInstanceUsecase.call<T>(instance, key).getOrThrow();
  }
}
