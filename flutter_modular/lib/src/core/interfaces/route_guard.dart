//ignore:one_member_abstracts

import '../models/modular_router.dart';

// ignore: one_member_abstracts
abstract class RouteGuard {
  Future<bool> canActivate(String path, ModularRouter router);
}
