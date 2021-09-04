import 'package:flutter_modular/src/presenter/models/route.dart';
import 'package:modular_core/modular_core.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'bind.dart';

class Module extends RouteContextImpl {
  @override
  List<Module> get imports => const [];

  @override
  List<Bind> get binds => const [];

  @override
  List<ModularRoute> get routes => const [];

  @override
  ModularRoute copy(covariant ParallelRoute parent, covariant ParallelRoute route) {
    final newRoute = super.copy(parent, route) as ParallelRoute;
    return newRoute.copyWith(
      customTransition: route.customTransition ?? parent.customTransition,
      transition: route.transition ?? parent.transition,
      duration: route.duration ?? parent.duration,
    );
  }
}
