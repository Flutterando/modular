import 'package:modular_core/modular_core.dart';

class Bind<T extends Object> extends BindContract<T> {
  Bind(
    super.factoryFunction, {
    super.isSingleton = true,
    super.isLazy = true,
    super.export = false,
    super.isScoped = false,
    super.onDispose,
  });

  ///Bind  an already exist 'Instance' of object..
  static Bind<T> instance<T extends Object>(T instance, {bool export = false}) {
    return Bind<T>((i) => instance,
        isSingleton: false, isScoped: false, isLazy: true, export: export);
  }

  ///Bind a 'Singleton' class.
  ///Built together with the module.
  ///The instance will always be the same.
  static Bind<T> singleton<T extends Object>(T Function(Injector i) inject,
      {bool export = false, void Function(T)? onDispose}) {
    return Bind<T>(inject,
        isSingleton: true,
        isLazy: false,
        isScoped: false,
        export: export,
        onDispose: onDispose);
  }

  ///Create single instance for request.
  static Bind<T> scoped<T extends Object>(T Function(Injector i) inject,
      {bool export = false, void Function(T)? onDispose}) {
    return Bind<T>(inject,
        isSingleton: true,
        isLazy: true,
        isScoped: true,
        export: export,
        onDispose: onDispose);
  }

  ///Bind a factory. Always a new constructor when calling Modular.get
  static Bind<T> factory<T extends Object>(T Function(Injector i) inject,
      {bool export = false}) {
    return Bind<T>(inject,
        isSingleton: false, isLazy: true, isScoped: false, export: export);
  }

  @override
  BindContract<E> cast<E extends Object>() {
    return Bind<E>(
      factoryFunction as E Function(Injector i),
      export: export,
      isLazy: isLazy,
      isSingleton: isSingleton,
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
    return Bind<T>(
      factoryFunction ?? this.factoryFunction,
      export: export ?? this.export,
      isLazy: isLazy ?? this.isLazy,
      isScoped: isScoped ?? this.isScoped,
      isSingleton: isSingleton ?? this.isSingleton,
    );
  }
}

class BindInject<T extends Object> extends Bind<T> {
  late final T Function(Injector i) inject;

  BindInject(
    super.factoryFunction, {
    super.isSingleton = true,
    super.isLazy = true,
    super.isScoped = true,
    super.onDispose,
  }) : inject = factoryFunction;
}
