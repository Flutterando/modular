import 'package:modular_core/modular_core.dart';
import 'package:test/test.dart';

void main() {
  late InjectorImpl injector;
  late MyInjectModule instance;

  setUp(() {
    injector = InjectorImpl();
    instance = MyInjectModule();
  });

  test(' getProcessBinds()', () {
    var list = instance.getProcessBinds();
    expect(list.length, 6);

    instance.changeBinds([]);

    list = instance.getProcessBinds();
    expect(list.length, 0);
  });

  test('get bind', () {
    final bindString = instance.getBind<String>(injector)?.value;
    expect(bindString, 'Jacob');

    final bindStringSingleton = instance.getBind<String>(injector)?.value;
    expect(bindStringSingleton, 'Jacob');

    final bindDouble = instance.getBind<double>(injector)?.value;
    expect(bindDouble, 0.0);

    final bindInt = instance.getBind<Map>(injector)?.value;
    expect(bindInt, isA<Map>());
  });

  test('get bind by interface', () {
    final bindRepository = instance.getBind<Repository>(injector)?.value;
    expect(bindRepository, isA<Repository>());

    final bindIRepository = instance.getBind<IRepository>(injector)?.value;
    expect(bindIRepository, isA<IRepository>());
  });
  test('get bind by interface with Disposable', () async {
    final bindRepository = instance.getBind<Repository>(injector)?.value;
    expect(bindRepository, isA<Repository>());
    instance.remove<Repository>();

    expect(bindRepository?.isDisposed, true);
  });

  test('get imported bind', () {
    final bindWithExportFlag = instance.getBind<Map>(injector)?.value;
    expect(bindWithExportFlag, isNotNull);

    final bindWithlessExportFlag = instance.getBind<List>(injector)?.value;
    expect(bindWithlessExportFlag, isNull);
  });

  test('remove bind', () {
    expect(instance.remove<String>(), false);

    final bindString = instance.getBind<String>(injector)?.value;
    expect(bindString, 'Jacob');

    expect(instance.remove<String>(), true);
  });

  test('remove bind with dispose resolver', () {
    expect(instance.remove<String>(), false);

    final bindString = instance.getBind<String>(injector)?.value;
    expect(bindString, 'Jacob');
    expect(instance.remove<String>(), true);
  });

  test('remove scopedBinds', () {
    expect(instance.removeScopedBind(), false);

    final bindString = instance.getBind<String>(injector)?.value;
    expect(bindString, 'Jacob');

    expect(instance.removeScopedBind(), true);
  });

  test('dispose', () {
    instance.dispose();

    final bindString = instance.getBind<String>(injector)?.value;
    expect(bindString, 'Jacob');
    expect(instance.instanciatedSingletons.length, 1);

    instance.dispose();
    expect(instance.instanciatedSingletons.length, 0);
  });

  test('isReady', () async {
    await instance.isReady();
    final bindSet = instance.getBind<Set>(injector)?.value;
    expect(bindSet, isA<Set>());
  });

  test('instantiateSingletonBinds', () {
    instance.instantiateSingletonBinds(
        [BindEntry(bind: _Bind((i) => 0.0), value: 0.0)], injector);
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
        AsyncBind<Set>((i) => Future.value(<dynamic>{})),
        _Bind((i) => 'Jacob', scoped: true),
        _Bind((i) => true),
        _Bind<double>((i) => 0.0, lazy: false),
        _Bind(
          (i) => Repository(),
          onDispose: (value) => value,
        ),
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
    void Function(T value)? onDispose,
  }) : super(
          factoryFunction,
          export: export,
          isLazy: lazy,
          isScoped: scoped,
          onDispose: onDispose,
        );

  @override
  BindContract<E> cast<E extends Object>() {
    return _Bind<E>(
      factoryFunction as E Function(Injector),
      export: export,
      lazy: isLazy,
      onDispose: onDispose != null ? onDispose as void Function(E) : null,
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

abstract class IRepository {
  bool isDisposed = false;
}

class Repository extends IRepository with Disposable {
  @override
  void dispose() {
    isDisposed = true;
  }
}

class AsyncBind<T extends Object> extends _Bind<Future<T>>
    implements AsyncBindContract<T> {
  @override
  final Future<T> Function(Injector i) asyncInject;

  AsyncBind(this.asyncInject, {bool export = false})
      : super(asyncInject, export: export);

  @override
  Future<T> resolveAsyncBind() async {
    final bind = await asyncInject(modularTracker.injector);
    return bind;
  }

  @override
  Future<BindContract<T>> convertToBind() async {
    final bindValue = await resolveAsyncBind();
    return _Bind<T>((i) => bindValue, export: export);
  }
}
