import 'package:modular_core/modular_core.dart';

/// Represents and manufactures an object instance that can be injected.
class Bind<T extends Object> extends BindContract<T> {
  Bind(
    T Function(Injector i) factoryFunction, {
    bool isSingleton = true,
    bool isLazy = true,
    bool export = false,
    bool alwaysSerialized = false,
    void Function(T value)? onDispose,
    dynamic Function(T value)? selector,
  }) : super(
          factoryFunction,
          isSingleton: isSingleton,
          isLazy: isLazy,
          export: export,
          isScoped: false,
          alwaysSerialized: alwaysSerialized,
          onDispose: onDispose,
          selector: selector,
        );

  @override
  Bind<E> cast<E extends Object>() {
    return Bind<E>(
      factoryFunction as E Function(Injector i),
      alwaysSerialized: alwaysSerialized,
      export: export,
      isLazy: isLazy,
      isSingleton: isSingleton,
      selector: selector != null ? selector as Function(E) : null,
      onDispose: onDispose != null ? onDispose as void Function(E) : null,
    );
  }

  ///Bind  an already exist 'Instance' of object..
  static Bind<T> instance<T extends Object>(T instance,
      {bool export = false, dynamic Function(T value)? selector}) {
    return Bind<T>((i) => instance,
        isSingleton: false, isLazy: true, export: export, selector: selector);
  }

  ///Bind a 'Singleton' class.
  ///Built together with the module.
  ///The instance will always be the same.
  static Bind<T> singleton<T extends Object>(T Function(Injector i) inject,
      {bool export = false,
      void Function(T value)? onDispose,
      dynamic Function(T value)? selector}) {
    return Bind<T>(inject,
        isSingleton: true,
        isLazy: false,
        export: export,
        onDispose: onDispose,
        selector: selector);
  }

  ///Create single instance for request.
  static Bind<T> lazySingleton<T extends Object>(T Function(Injector i) inject,
      {bool export = false,
      void Function(T value)? onDispose,
      dynamic Function(T value)? selector}) {
    return Bind<T>(inject,
        isSingleton: true,
        isLazy: true,
        export: export,
        onDispose: onDispose,
        selector: selector);
  }

  ///Bind a factory. Always a new constructor when calling Modular.get
  static Bind<T> factory<T extends Object>(
    T Function(Injector i) inject, {
    bool export = false,
  }) {
    return Bind<T>(inject, isSingleton: false, isLazy: true, export: export);
  }

  @override
  Bind<T> copyWith(
      {T Function(Injector i)? factoryFunction,
      bool? isSingleton,
      bool? isLazy,
      bool? export,
      bool? isScoped,
      bool? alwaysSerialized,
      void Function(T value)? onDispose,
      Function(T value)? selector}) {
    return Bind<T>(
      factoryFunction ?? this.factoryFunction,
      alwaysSerialized: alwaysSerialized ?? this.alwaysSerialized,
      export: export ?? this.export,
      isLazy: isLazy ?? this.isLazy,
      isSingleton: isSingleton ?? this.isSingleton,
      selector: selector ?? this.selector,
      onDispose: onDispose ?? this.onDispose,
    );
  }
}

/// AsyncBind represents an asynchronous Bind that can be resolved before module initialization by calling Modular.isModuleReady() or called with Modular.getAsync()
class AsyncBind<T extends Object> extends Bind<Future<T>>
    implements AsyncBindContract<T> {
  @override
  final Future<T> Function(Injector i) asyncInject;

  late final void Function(T value)? _localOnDispose;

  AsyncBind(
    this.asyncInject, {
    bool export = false,
    void Function(T value)? onDispose,
  })  : _localOnDispose = onDispose,
        super(asyncInject, export: export);

  @override
  Future<T> resolveAsyncBind() async {
    final bind = await asyncInject(modularTracker.injector);
    return bind;
  }

  @override
  Future<BindContract<T>> convertToBind() async {
    final bindValue = await resolveAsyncBind();
    return Bind<T>((i) => bindValue,
        export: export, alwaysSerialized: true, onDispose: _localOnDispose);
  }

  @override
  AsyncBind<T> copyWith(
      {Future<T> Function(Injector i)? factoryFunction,
      bool? isSingleton,
      bool? isLazy,
      bool? export,
      bool? isScoped,
      bool? alwaysSerialized,
      void Function(Future<T> value)? onDispose,
      Function(Future<T> value)? selector}) {
    return AsyncBind(
      factoryFunction ?? this.factoryFunction,
      export: export ?? this.export,
    );
  }
}

/// Specific instance for modular_codegen
class BindInject<T extends Object> extends Bind<T> {
  final T Function(Injector i) inject;

  BindInject(
    this.inject, {
    bool isSingleton = true,
    bool isLazy = true,
  }) : super(
          inject,
          isSingleton: isSingleton,
          isLazy: isLazy,
        );
}
