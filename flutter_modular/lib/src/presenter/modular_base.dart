import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../domain/usecases/get_arguments.dart';
import '../domain/usecases/reassemble_tracker.dart';
import 'package:modular_core/modular_core.dart';

import '../domain/usecases/dispose_bind.dart';
import '../domain/usecases/finish_module.dart';
import '../domain/usecases/get_bind.dart';
import '../domain/usecases/module_ready.dart';
import '../domain/usecases/set_arguments.dart';
import '../domain/usecases/start_module.dart';
import 'errors/errors.dart';
import 'package:meta/meta.dart';

import 'navigation/modular_route_information_parser.dart';
import 'navigation/modular_router_delegate.dart';

abstract class IModularBase {
  /// Finishes all trees(BindContext and RouteContext).
  void destroy();

  /// checks if all asynchronous binds are ready to be used synchronously of all BindContext of Tree.
  Future<void> isModuleReady<M extends Module>();

  // Responsible for starting the app.
  /// It should only be called once, but it should be the first method to be called before a route or bind lookup.
  void init(Module module);

  /// value is '/';
  String get initialRoute;

  /// Retrieves the ModularArguments instance.
  /// A ModularArguments is renewed every search for a new route.
  ModularArguments get args;

  /// Retrieves the IModularNavigator instance.
  /// By default the instance that controls all routes globally is returned,
  /// but this behavior can be replaced in ModularNavigator by a custom instance:
  ///
  /// Modular.navigatorDelegate = MyNavigatorDelegate();
  IModularNavigator get to;

  /// replaces the default ModularNavigator with a custom instance:
  /// Ideal for Unit Testing.
  /// Modular.navigatorDelegate = MyNavigatorDelegate()
  IModularNavigator? navigatorDelegate;

  void debugPrintModular(String text);

  /// Request an instance by [Type]
  B get<B extends Object>({B? defaultValue});

  @internal
  BindEntry<B> getBindEntry<B extends Object>({B? defaultValue});

  /// Request an async instance by [Type]
  Future<B> getAsync<B extends Object>({B? defaultValue});

  /// Dispose a [Bind] by [Type]
  bool dispose<B extends Object>();

  /// called whennever throw hot-reload
  void reassemble();

  /// Navigator 2.0 initializator: RouteInformationParser
  ModularRouteInformationParser get routeInformationParser;

  /// Navigator 2.0 initializator: RouterDelegate
  ModularRouterDelegate get routerDelegate;

  /// Change the starting route path
  void setInitialRoute(String initialRoute);

  /// Change a list of NavigatorObserver objects
  void setObservers(List<NavigatorObserver> navigatorObservers);

  /// Change the navigatorKey
  void setNavigatorKey(GlobalKey<NavigatorState>? key);

  /// Change the navigatorKey
  void setArguments(dynamic arguments);

  @visibleForTesting
  String get initialRoutePath;
}

class ModularBase implements IModularBase {
  final DisposeBind disposeBind;
  final FinishModule finishModule;
  final GetBind getBind;
  final GetArguments getArguments;
  final SetArguments setArgumentsUsecase;
  final ReassembleTracker reassembleTracker;
  final StartModule startModule;
  final IsModuleReady isModuleReadyUsecase;
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

  ModularBase({
    required this.routeInformationParser,
    required this.routerDelegate,
    required this.disposeBind,
    required this.reassembleTracker,
    required this.getArguments,
    required this.finishModule,
    required this.getBind,
    required this.startModule,
    required this.isModuleReadyUsecase,
    required this.navigator,
    required this.setArgumentsUsecase,
  });

  @override
  bool dispose<B extends Object>() =>
      disposeBind<B>().getOrElse((left) => false);

  @override
  BindEntry<B> getBindEntry<B extends Object>({B? defaultValue}) {
    return getBind<B>().getOrElse((left) {
      if (defaultValue != null) {
        return BindEntry<B>(
            bind: Bind.instance(defaultValue), value: defaultValue);
      }
      throw left;
    });
  }

  @override
  B get<B extends Object>({B? defaultValue}) {
    return getBindEntry<B>(defaultValue: defaultValue).value;
  }

  @override
  Future<B> getAsync<B extends Object>({B? defaultValue}) {
    return getBind<Future<B>>().map((r) => r.value).getOrElse((left) {
      if (defaultValue != null) {
        return Future.value(defaultValue);
      }
      throw left;
    });
  }

  @override
  Future<void> isModuleReady<M extends Module>() =>
      isModuleReadyUsecase.call<M>();

  @override
  void destroy() {
    _moduleHasBeenStarted = false;
    finishModule();
  }

  @override
  void init(Module module) {
    if (!_moduleHasBeenStarted) {
      startModule(module).fold(
          (l) => throw l, (r) => debugPrint('${module.runtimeType} started!'));
      _moduleHasBeenStarted = true;

      setPrintResolver(debugPrint);
    } else {
      throw ModuleStartedException(
          'Module ${module.runtimeType} is already started');
    }
  }

  @override
  IModularNavigator get to => navigatorDelegate ?? navigator;

  @override
  ModularArguments get args =>
      getArguments().getOrElse((l) => ModularArguments.empty());

  final flags = ModularFlags();

  @override
  void debugPrintModular(String text) {
    if (flags.isDebug) {
      debugPrint(text);
    }
  }

  @override
  final String initialRoute = '/';

  @internal
  @override
  void reassemble() {
    reassembleTracker();
  }

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
}
