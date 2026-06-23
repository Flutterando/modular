/// flutter_modular v7 — clean rewrite (work in progress).
///
/// Navigator 2.0 (route matching + page stack + guards + transitions), the
/// module system (`createModule` / `ModularContext`), page-scoped state
/// (`provide` / `Scoped` + `context.watch`/`read`, `Consumer`/`Selector`;
/// `addChangeNotifier`/`addStream` as the rule, `addStreamable`/`addListenable`
/// for BLoC/Cubit-style objects, `add` for non-reactive resources), and nested
/// routes (`children` + `RouterOutlet`).
library;

export 'src/app/modular_app.dart';
export 'src/module/module.dart';
export 'src/navigation/modular_navigation.dart';
export 'src/navigation/modular_router_config.dart';
export 'src/navigation/outlet.dart' show RouterOutlet, RouterOutletState;
export 'src/navigation/transition.dart' show TransitionType;
export 'src/route/modular_route.dart';
export 'src/route/route_state.dart';
export 'src/state/consumer.dart';
export 'src/state/scoped.dart'
    show Disposable, ModularStateX, Scoped, StreamValue;
