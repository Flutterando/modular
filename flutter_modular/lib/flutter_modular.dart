library flutter_modular;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/flutter_modular_module.dart';
import 'package:modular_core/modular_core.dart';

import 'src/presenter/modular_base.dart';
import 'src/presenter/navigation/modular_page.dart';
import 'src/presenter/navigation/modular_router_delegate.dart';
import 'src/presenter/navigation/router_outlet_delegate.dart';

export 'package:modular_core/modular_core.dart'
    show
        ModularRoute,
        RouteManager,
        Disposable,
        Module,
        BindConfig,
        Injector,
        AutoInjectorException,
        ModularArguments,
        setPrintResolver;

export 'src/presenter/extensions/route_manager_ext.dart';
export 'src/presenter/guards/route_guard.dart';
export 'src/presenter/models/child_route.dart';
export 'src/presenter/models/modular_args.dart';
export 'src/presenter/models/modular_navigator.dart';
export 'src/presenter/models/module_route.dart';
export 'src/presenter/models/redirect_to_route.dart';
export 'src/presenter/models/route.dart';
export 'src/presenter/models/wildcard_route.dart';
export 'src/presenter/navigation/transitions/page_transition.dart';
export 'src/presenter/navigation/transitions/transitions.dart';
export 'src/presenter/widgets/modular_app.dart';
export 'src/presenter/widgets/navigation_listener.dart';

IModularBase? _modular;

/// Instance of Modular for search binds and route.
// ignore: non_constant_identifier_names
IModularBase get Modular {
  _modular ??= injector.get<IModularBase>();
  return _modular!;
}

/// clean Modular
void cleanModular() {
  _modular?.destroy();
  _modular = null;
}

/// clean all
void cleanGlobals() {
  cleanModular();
}

/// Extension to add args in AutoInjector class
extension InjectorExtends on Injector {
  /// get arguments
  ModularArguments get args => injector.get<Tracker>().arguments;
}

/// It acts as a Nested Browser that will be populated
/// by the children of this route.
class RouterOutlet extends StatefulWidget {
  /// An interface for observing the behavior of a [Navigator].
  final List<NavigatorObserver>? observers;

  /// It acts as a Nested Browser that will be populated
  /// by the children of this route.
  const RouterOutlet({Key? key, this.observers}) : super(key: key);

  @override
  RouterOutletState createState() => RouterOutletState();
}

/// visible for test
@visibleForTesting
class RouterOutletState extends State<RouterOutlet> {
  late GlobalKey<NavigatorState> _navigatorKey;
  RouterOutletDelegate? _delegate;
  ChildBackButtonDispatcher? _backButtonDispatcher;

  /// Get all current observers
  List<NavigatorObserver> get currentObservers =>
      widget.observers ?? <NavigatorObserver>[];

  @override
  void initState() {
    super.initState();
    _navigatorKey = GlobalKey<NavigatorState>();

    Modular.to.addListener(listener);
  }

  /// visible for test
  @visibleForTesting
  void listener() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modal = ModalRoute.of(context)?.settings as ModularPage?;
    if (modal == null) {
      return;
    }
    _delegate ??= RouterOutletDelegate(
      modal.route.uri.toString(),
      injector.get<ModularRouterDelegate>(),
      _navigatorKey,
      currentObservers,
    );

    /// Prevent RouterOutlent to take back button priority
    /// when the new named route, is not a children
    if (_newRouteIsNotChildren(modal.route)) {
      _backButtonDispatcher = null;
      return;
    }
    final router = Router.of(context);
    _backButtonDispatcher = router.backButtonDispatcher //
        ?.createChildBackButtonDispatcher();
  }

  bool _newRouteIsNotChildren(ParallelRoute route) {
    return !route.children.any((e) => Modular.to.path.contains(e.name));
  }

  @override
  void dispose() {
    super.dispose();
    Modular.to.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    _backButtonDispatcher?.takePriority();
    return Router(
      routerDelegate: _delegate!,
      backButtonDispatcher: _backButtonDispatcher,
    );
  }
}
