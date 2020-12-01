//ignore:one_member_abstracts

import '../models/modular_router.dart';

mixin RouteGuard {
  Future<bool> canActivate(String path, ModularRouter router);
}
