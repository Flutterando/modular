import 'package:flutter/widgets.dart';
import 'package:modular_core/modular_core.dart';

import 'errors/errors.dart';
import 'models/modular_args.dart';
import 'models/modular_navigator.dart';
import 'navigation/modular_route_information_parser.dart';
import 'navigation/modular_router_delegate.dart';

abstract class IModularBase {
  /// Finishes all trees(BindContext and RouteContext).
  void destroy();

  /// Responsible for starting the app.
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
  B get<B extends Object>();

  /// Request an instance by [Type]
  /// returning [null] if instance not founded.
  B? tryGet<B extends Object>();

  /// Dispose a [Bind] by [Type]
  bool dispose<B extends Object>();

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
  final Tracker tracker;
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
    required this.navigator,
    required this.tracker,
  });

  @override
  bool dispose<B extends Object>() {
    return tracker.dispose<B>();
  }

  @override
  B get<B extends Object>() {
    return tracker.injector.get<B>();
  }

  @override
  B? tryGet<B extends Object>() {
    return tracker.injector.tryGet<B>();
  }

  @override
  void destroy() {
    _moduleHasBeenStarted = false;
    tracker.finishApp();
  }

  @override
  void init(Module module) {
    if (!_moduleHasBeenStarted) {
      tracker.runApp(module);
      _moduleHasBeenStarted = true;
    } else {
      throw ModuleStartedException(
          'Module ${module.runtimeType} is already started');
    }
  }

  @override
  IModularNavigator get to => navigatorDelegate ?? navigator;

  @override
  ModularArguments get args => tracker.arguments;

  final flags = ModularFlags();

  @override
  void debugPrintModular(String text) {
    if (flags.isDebug) {
      debugPrint(text);
    }
  }

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
    tracker.setArguments(args.copyWith(data: data));
  }
}
