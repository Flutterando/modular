library flutter_modular;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/src/flutter_modular_module.dart';
import 'package:modular_core/modular_core.dart';

import 'src/domain/usecases/get_arguments.dart';
import 'src/presenter/modular_base.dart';
import 'src/presenter/navigation/modular_page.dart';
import 'src/presenter/navigation/modular_router_delegate.dart';
import 'src/presenter/navigation/router_outlet_delegate.dart';

export 'package:flutter_modular_annotations/flutter_modular_annotations.dart';
export 'package:modular_core/modular_core.dart'
    show ModularRoute, Disposable, ReassembleMixin;

export 'src/presenter/guards/route_guard.dart';
export 'src/presenter/models/bind.dart';
export 'src/presenter/models/child_route.dart';
export 'src/presenter/models/modular_args.dart';
export 'src/presenter/models/modular_navigator.dart';
export 'src/presenter/models/module.dart';
export 'src/presenter/models/module_route.dart';
export 'src/presenter/models/redirect_to_route.dart';
export 'src/presenter/models/route.dart';
export 'src/presenter/models/wildcard_route.dart';
export 'src/presenter/navigation/transitions/page_transition.dart';
export 'src/presenter/navigation/transitions/transitions.dart';
export 'src/presenter/widgets/modular_app.dart';
export 'src/presenter/widgets/modular_state.dart';
export 'src/presenter/widgets/navigation_listener.dart';
export 'src/presenter/widgets/widget_module.dart';

IModularBase? _modular;

/// Instance of Modular for search binds and route.
// ignore: non_constant_identifier_names
IModularBase get Modular {
  _modular ??= injector<IModularBase>();
  return _modular!;
}

void cleanModular() {
  _modular?.destroy();
  _modular = null;
}

void cleanGlobals() {
  cleanTracker();
  cleanModular();
  cleanInjector();
}

extension InjectorExtends on Injector {
  /// get arguments
  ModularArguments get args => injector
      .get<GetArguments>()
      .call()
      .getOrElse((l) => ModularArguments.empty());
}

/// It acts as a Nested Browser that will be populated by the children of this route.
class RouterOutlet extends StatefulWidget {
  final List<NavigatorObserver>? observers;
  const RouterOutlet({Key? key, this.observers}) : super(key: key);

  @override
  RouterOutletState createState() => RouterOutletState();
}

class RouterOutletState extends State<RouterOutlet> {
  late GlobalKey<NavigatorState> navigatorKey;
  RouterOutletDelegate? delegate;
  late ChildBackButtonDispatcher _backButtonDispatcher;

  List<NavigatorObserver> get currentObservers =>
      widget.observers ?? <NavigatorObserver>[];

  @override
  void initState() {
    super.initState();
    navigatorKey = GlobalKey<NavigatorState>();

    Modular.to.addListener(listener);
  }

  @visibleForTesting
  void listener() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modal = (ModalRoute.of(context)?.settings as ModularPage);
    delegate ??= RouterOutletDelegate(modal.route.uri.toString(),
        injector.get<ModularRouterDelegate>(), navigatorKey, currentObservers);
    final router = Router.of(context);
    _backButtonDispatcher =
        router.backButtonDispatcher!.createChildBackButtonDispatcher();
  }

  @override
  void dispose() {
    super.dispose();
    Modular.to.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    _backButtonDispatcher.takePriority();
    return Router(
      routerDelegate: delegate!,
      backButtonDispatcher: _backButtonDispatcher,
    );
  }
}
