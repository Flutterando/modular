//ignore:one_member_abstracts

import 'modular_route.dart';

// ignore: one_member_abstracts
abstract class RouteGuard {
  Future<bool> canActivate(String path, ModularRoute router);
}
