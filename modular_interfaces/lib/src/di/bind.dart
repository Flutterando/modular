import 'injector.dart';

abstract class BindContract<T extends Object> {
  final T Function(Injector i) factoryFunction;

  Type get bindType => T;

  ///single instance
  final bool isSingleton;

  ///create single instance for request
  final bool isScoped;

  ///export bind for others modules
  final bool export;

  ///When 'true', the object is instantiated only the first time it is called.
  ///When 'false', the object is instantiated along with the module.
  final bool isLazy;

  BindContract(
    this.factoryFunction, {
    this.isSingleton = true,
    this.isLazy = true,
    this.export = false,
    this.isScoped = false,
  }) : assert((isSingleton || isLazy),
            r"'singleton' can't be false if 'lazy' is also false");
}

/// For empty instance binds.
class BindEmpty extends BindContract<Object> {
  BindEmpty() : super((e) => Object());
}

class SingletonBind<T extends Object> {
  final BindContract<T> bind;
  final T value;

  SingletonBind({required this.bind, required this.value});
}
