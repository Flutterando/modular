import 'package:modular_core/modular_core.dart';
import 'package:test/test.dart';

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
    expect(module.instanciatedSingletons.length, 3);

    final bindString = injector.get<String>();
    expect(bindString, 'Jacob');
    expect(module.instanciatedSingletons.length, 4);

    injector.removeScopedBinds();
    expect(module.instanciatedSingletons.length, 3);
  });
  test('dispose bind', () {
    expect(module.instanciatedSingletons.length, 3);
    injector.dispose<double>();
    expect(module.instanciatedSingletons.length, 2);
  });

  test('reassemble', () {
    final withReassemble = injector.get<MyObjectWithReassemble>();
    final withlessReassemble = injector.get<MyObjectWithlessReassemble>();
    expect(withReassemble.count, 0);
    expect(withlessReassemble.count, 0);

    injector.reassemble();

    expect(withReassemble.count, 1);
    expect(withlessReassemble.count, 0);
  });
}

class Char {
  const Char();
}

class MyInjectModule extends BindContextImpl {
  @override
  List<BindContract> get binds => [
        _Bind<String>((i) => 'Jacob', scoped: true),
        _Bind<bool>((i) => true),
        _Bind<double>((i) => 0.0, lazy: false),
        _Bind<MyObjectWithReassemble>((i) => MyObjectWithReassemble(),
            lazy: false),
        _Bind<MyObjectWithlessReassemble>((i) => MyObjectWithlessReassemble(),
            lazy: false),
      ];
}

class _Bind<T extends Object> extends BindContract<T> {
  _Bind(
    T Function(Injector i) factoryFunction, {
    bool export = false,
    bool scoped = false,
    bool lazy = true,
  }) : super(
          factoryFunction,
          export: export,
          isLazy: lazy,
          isScoped: scoped,
        );

  @override
  BindContract<E> cast<E extends Object>() {
    return _Bind<E>(
      factoryFunction as E Function(Injector),
      export: export,
      lazy: isLazy,
      scoped: isScoped,
    );
  }

  @override
  BindContract<T> copyWith({
    T Function(Injector i)? factoryFunction,
    bool? isSingleton,
    bool? isLazy,
    bool? export,
    bool? isScoped,
    bool? alwaysSerialized,
    void Function(T value)? onDispose,
    Function(T value)? selector,
  }) {
    return _Bind(
      factoryFunction ?? this.factoryFunction,
      lazy: isLazy ?? this.isLazy,
      export: export ?? this.export,
      scoped: isScoped ?? this.isScoped,
    );
  }
}

class MyObjectWithReassemble with ReassembleMixin {
  var count = 0;

  @override
  void reassemble() {
    count++;
  }
}

class MyObjectWithlessReassemble {
  var count = 0;

  void reassemble() {
    count++;
  }
}
