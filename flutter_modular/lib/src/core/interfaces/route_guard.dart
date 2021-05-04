//ignore:one_member_abstracts

import 'modular_route.dart';

// ignore: one_member_abstracts
abstract class RouteGuard {
  RouteGuard(this.guardedRoute);

  final String? guardedRoute;

  Future<bool> canActivate(String path, ModularRoute router);
}