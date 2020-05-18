abstract class GuardExecutor {
  onGuarded(String path, bool isActive);
}

abstract class RouteGuard {
  bool canActivate(String url);

  List<GuardExecutor> get executors;
}
