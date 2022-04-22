import 'injector.dart';

abstract class BindContract<T extends Object> {
  final T Function(Injector i) factoryFunction;

  Type get bindType => T;

  ///single instance
  final bool isSingleton;

  /// flag for indicate serialization
  final bool alwaysSerialized;

  ///create single instance for request
  final bool isScoped;

  ///export bind for others modules
  final bool export;

  ///When 'true', the object is instantiated only the first time it is called.
  ///When 'false', the object is instantiated along with the module.
  final bool isLazy;

  ///Called in module`s dispose.
  final void Function(T value)? onDispose;

  /// Generate reactive object
  final dynamic Function(T value)? notifier;

  BindContract(
    this.factoryFunction, {
    this.isSingleton = true,
    this.isLazy = true,
    this.export = false,
    this.isScoped = false,
    this.alwaysSerialized = false,
    this.onDispose,
    this.notifier,
  }) : assert((isSingleton || isLazy), r"'singleton' can't be false if 'lazy' is also false");

  BindContract<E> cast<E extends Object>();

  dynamic onNotifierFunc(Object o) => notifier?.call(o as T);

  dynamic onDisposeFunc(Object o) => onDispose?.call(o as T);
}

/// For empty instance binds.
class BindEmpty extends BindContract<Object> {
  BindEmpty() : super((e) => Object());

  @override
  BindContract<E> cast<E extends Object>() {
    throw UnimplementedError();
  }
}

class BindEntry<T extends Object> {
  final BindContract<T> bind;
  final T value;

  BindEntry({required this.bind, required this.value});

  BindEntry<E> cast<E extends Object>() {
    return BindEntry<E>(bind: bind.cast<E>(), value: value as E);
  }

  void dispose() {
    bind.onDisposeFunc(value);
  }
}
