import 'package:modular_core/modular_core.dart';
import 'package:modular_core/src/di/bind_context.dart';
import 'package:modular_core/src/di/injector.dart';
import 'package:modular_interfaces/modular_interfaces.dart';
import 'package:test/test.dart';

void main() {
  late InjectorImpl injector;
  late MyInjectModule instance;

  setUp(() {
    injector = InjectorImpl();
    instance = MyInjectModule();
  });

  test('get bind', () {
    final bindString = instance.getBind<String>(injector);
    expect(bindString, 'Jacob');

    final bindStringSingleton = instance.getBind<String>(injector);
    expect(bindStringSingleton, 'Jacob');

    final bindDouble = instance.getBind<double>(injector);
    expect(bindDouble, 0.0);

    final bindInt = instance.getBind<Map>(injector);
    expect(bindInt, isA<Map>());
  });

  test('get bind by interface', () {
    final bindRepository = instance.getBind<Repository>(injector);
    expect(bindRepository, isA<Repository>());

    final bindIRepository = instance.getBind<IRepository>(injector);
    expect(bindIRepository, isA<IRepository>());
  });

  test('get imported bind', () {
    final bindWithExportFlag = instance.getBind<Map>(injector);
    expect(bindWithExportFlag, isNotNull);

    final bindWithlessExportFlag = instance.getBind<List>(injector);
    expect(bindWithlessExportFlag, isNull);
  });

  test('remove bind', () {
    expect(instance.remove<String>(), false);

    final bindString = instance.getBind<String>(injector);
    expect(bindString, 'Jacob');

    expect(instance.remove<String>(), true);
  });

  test('remove bind with dispose resolver', () {
    expect(instance.remove<String>(), false);

    final bindString = instance.getBind<String>(injector);
    expect(bindString, 'Jacob');
    setDisposeResolver((t) {
      expect(t, 'Jacob');
    });
    setDisposeResolver((t) {});

    expect(instance.remove<String>(), true);
  });

  test('remove scopedBinds', () {
    expect(instance.removeScopedBind(), false);

    final bindString = instance.getBind<String>(injector);
    expect(bindString, 'Jacob');

    expect(instance.removeScopedBind(), true);
  });

  test('dispose', () {
    instance.dispose();

    final bindString = instance.getBind<String>(injector);
    expect(bindString, 'Jacob');
    expect(instance.instanciatedSingletons.length, 1);

    instance.dispose();
    expect(instance.instanciatedSingletons.length, 0);
  });

  test('isReady', () async {
    await instance.isReady();
    final bindSet = instance.getBind<Set>(injector);
    expect(bindSet, isA<Set>());
  });

  test('instantiateSingletonBinds', () {
    instance.instantiateSingletonBinds([SingletonBind(bind: _Bind((i) => 0.0), value: 0.0)], injector);
    expect(instance.instanciatedSingletons.length, 1);
  });
}

class MyInjectModule extends BindContextImpl {
  @override
  List<BindContext> get imports => [
        MyInjectModule2(),
      ];

  @override
  List<BindContract> get binds => [
        AsyncBind<Set>((i) => Future.value(Set())),
        _Bind((i) => 'Jacob', scoped: true),
        _Bind((i) => true),
        _Bind<double>((i) => 0.0, lazy: false),
        _Bind((i) => Repository()),
      ];
}

class MyInjectModule2 extends BindContextImpl {
  @override
  List<BindContract> get binds => [
        _Bind<Map>((i) => {}, export: true),
        _Bind<List>((i) => []),
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
}

abstract class IRepository {}

class Repository extends IRepository {}

class AsyncBind<T extends Object> extends _Bind<Future<T>> implements AsyncBindContract<T> {
  @override
  final Future<T> Function(Injector i) asyncInject;

  AsyncBind(this.asyncInject, {bool export = false}) : super(asyncInject, export: export);

  @override
  Future<T> resolveAsyncBind() async {
    final bind = await asyncInject(ModularTracker.injector);
    return bind;
  }

  @override
  Future<BindContract<T>> convertToAsyncBind() async {
    final bindValue = await resolveAsyncBind();
    return _Bind<T>((i) => bindValue, export: export);
  }
}
