import 'package:flutter_modular/src/domain/services/bind_service.dart';
import 'package:flutter_modular/src/domain/services/module_service.dart';
import 'package:flutter_modular/src/domain/services/route_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';

class BindServiceMock extends Mock implements BindService {}

class RouteServiceMock extends Mock implements RouteService {}

class ModuleMock extends Mock implements Module {}

class ModuleServiceMock extends Mock implements ModuleService {}

class ModularRouteMock extends Mock implements ModularRoute {}

class InjectorMock extends Mock implements AutoInjector {}

class TrackerMock extends Mock implements Tracker {}

extension WhenExtension on When<void> {
  void _stubFunc() {}

  void thenReturnVoid() {
    thenReturn(_stubFunc());
  }

  void thenAnswerVoid() {
    thenAnswer((_) => Future.value());
  }
}
