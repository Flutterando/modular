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

  BindContract(
    this.factoryFunction, {
    this.isSingleton = true,
    this.isLazy = true,
    this.export = false,
    this.isScoped = false,
    this.alwaysSerialized = false,
    this.onDispose,
  }) : assert((isSingleton || isLazy), r"'singleton' can't be false if 'lazy' is also false");
}

/// For empty instance binds.
class BindEmpty extends BindContract<Object> {
  BindEmpty() : super((e) => Object());
}

class BindEntry<T extends Object> {
  final BindContract bind;
  final T value;

  BindEntry({required this.bind, required this.value});

  BindEntry<E> cast<E extends Object>() {
    return BindEntry<E>(bind: bind, value: value as E);
  }
}
