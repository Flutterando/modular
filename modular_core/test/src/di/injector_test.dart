import 'package:modular_core/modular_core.dart';
import 'package:test/test.dart';

import 'bind_context_test.dart';

void main() {
  late InjectorImpl injector;
  late MyInjectModule module;

  setUp(() {
    injector = InjectorImpl();
    module = MyInjectModule();
    injector.addBindContext(module);
  });

  test('debugPrint', () async {
    int count = 0;

    injector.debugPrint('value');
    expect(count, 0);
    setPrintResolver((t) {
      count++;
    });
    injector.debugPrint('value');
    expect(count, 1);
    setPrintResolver((t) {});
  });

  test('isModuleReady', () async {
    expect(await injector.isModuleReady<MyInjectModule>(), true);
  });
  test('get bind', () {
    final bindString = injector.get<String>();
    expect(bindString, 'Jacob');

    expect(() => injector<Char>(), throwsA(isA<BindNotFound>()));
  });

  test('removeBindContext', () {
    expect(injector.isModuleAlive<MyInjectModule>(), true);
    injector.removeBindContext<MyInjectModule>();
    expect(injector.isModuleAlive<MyInjectModule>(), false);
  });

  test('Injector removeScopedBinds', () {
    expect(module.instanciatedSingletons.length, 1);

    final bindString = injector.get<String>();
    expect(bindString, 'Jacob');
    expect(module.instanciatedSingletons.length, 2);

    injector.removeScopedBinds();
    expect(module.instanciatedSingletons.length, 1);
  });
  test('dispose bind', () {
    expect(module.instanciatedSingletons.length, 1);
    injector.dispose<double>();
    expect(module.instanciatedSingletons.length, 0);
  });
}

class Char {
  const Char();
}
