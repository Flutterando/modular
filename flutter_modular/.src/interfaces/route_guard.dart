//ignore:one_member_abstracts
import '../routers/modular_router.dart';

mixin RouteGuard {
  Future<bool> canActivate(String path, ModularRoute router);
}
