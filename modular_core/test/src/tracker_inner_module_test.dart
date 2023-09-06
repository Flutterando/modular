import 'package:modular_core/modular_core.dart';
import 'package:test/test.dart';

void main() {
  test('Test duplicated instances', () {
    final tracker = Tracker(AutoInjector());
    tracker.runApp(AppModule());

    tracker.bindModule(AModule());
    tracker.injector.get<ControllerReducer>();
    expect(countInstance, 1);
    tracker.bindModule(BModule());
    tracker.injector.get<ControllerReducer>();
    expect(countInstance, 1);

    tracker.injector.get<ControllerReducer2>();
  });
}

class AppModule extends Module {}

class CoreModule extends Module {
  @override
  void exportedBinds(Injector i) {
    i.addSingleton(ControllerReducer.new);
  }
}

class AModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    i.add(Repository.new);
    i.addLazySingleton(ControllerReducer2.new);
  }
}

class BModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];
}

int countInstance = 0;

class ControllerReducer {
  ControllerReducer() {
    countInstance++;
  }
}

class ControllerReducer2 {
  final Repository repository;
  final ControllerReducer c1;

  ControllerReducer2(this.c1, this.repository);
}

class Repository {}
