import 'package:meta/meta.dart';

import '../di/bind.dart';
import '../route/route.dart';

abstract class Module {
  @visibleForOverriding
  List<Module> get imports => [];

  @visibleForOverriding
  List<Bind> get binds => [];

  @visibleForOverriding
  List<Bind> get exportedBinds => [];

  @visibleForOverriding
  List<ModularRoute> get routes => [];
}
