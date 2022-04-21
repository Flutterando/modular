import 'package:meta/meta.dart';
import 'package:modular_core/modular_core.dart';

/// Represents and manufactures an object instance that can be injected.
class Bind<T extends Object> extends BindContract<T> {
  @protected
  Bind(
    T Function(Injector i) factoryFunction, {
    bool isSingleton = true,
    bool isLazy = true,
    bool export = false,
    bool alwaysSerialized = false,
    void Function(T value)? onDispose,
  }) : super(
          factoryFunction,
          isSingleton: isSingleton,
          isLazy: isLazy,
          export: export,
          isScoped: false,
          alwaysSerialized: alwaysSerialized,
          onDispose: onDispose,
        );

  ///Bind  an already exist 'Instance' of object..
  static Bind<T> instance<T extends Object>(T instance, {bool export = false}) {
    return Bind<T>((i) => instance, isSingleton: false, isLazy: true, export: export);
  }

  ///Bind a 'Singleton' class.
  ///Built together with the module.
  ///The instance will always be the same.
  static Bind<T> singleton<T extends Object>(
    T Function(Injector i) inject, {
    bool export = false,
    void Function(T value)? onDispose,
  }) {
    return Bind<T>(inject, isSingleton: true, isLazy: false, export: export, onDispose: onDispose);
  }

  ///Create single instance for request.
  static Bind<T> lazySingleton<T extends Object>(
    T Function(Injector i) inject, {
    bool export = false,
    void Function(T value)? onDispose,
  }) {
    return Bind<T>(inject, isSingleton: true, isLazy: true, export: export, onDispose: onDispose);
  }

  ///Bind a factory. Always a new constructor when calling Modular.get
  static Bind<T> factory<T extends Object>(
    T Function(Injector i) inject, {
    bool export = false,
  }) {
    return Bind<T>(inject, isSingleton: false, isLazy: true, export: export);
  }
}

/// AsyncBind represents an asynchronous Bind that can be resolved before module initialization by calling Modular.isModuleReady() or called with Modular.getAsync()
class AsyncBind<T extends Object> extends Bind<Future<T>> implements AsyncBindContract<T> {
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
    return Bind<T>((i) => bindValue, export: export, alwaysSerialized: true, onDispose: _localOnDispose);
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
