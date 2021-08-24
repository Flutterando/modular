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
  }) : assert((isSingleton || isLazy), r"'singleton' can't be false if 'lazy' is also false");

  // ///Bind  an already exist 'Instance' of object..
  // static Bind<T> instance<T extends Object>(T instance, {bool export = false}) {
  //   return Bind<T>((i) => instance, isSingleton: false, isLazy: true, export: export);
  // }

  // ///Bind a 'Singleton' class.
  // ///Built together with the module.
  // ///The instance will always be the same.
  // static Bind<T> singleton<T extends Object>(T Function(Injector i) inject, {bool export = false}) {
  //   return Bind<T>(inject, isSingleton: true, isLazy: false, export: export);
  // }

  // ///Bind a 'Lazy Singleton' class.
  // ///Built only when called the first time using Modular.get.
  // ///The instance will always be the same.
  // static Bind<T> lazySingleton<T extends Object>(T Function(Injector i) inject, {bool export = false}) {
  //   return Bind<T>(inject, isSingleton: true, isLazy: true, export: export);
  // }

  // ///Bind a factory. Always a new constructor when calling Modular.get
  // static Bind<T> factory<T extends Object>(T Function(Injector i) inject, {bool export = false}) {
  //   return Bind<T>(inject, isSingleton: false, isLazy: true, export: export);
  // }

}

class BindInject<T extends Object> extends BindContract<T> {
  final T Function(Injector i) inject;

  ///single instance object?
  final bool isSingleton;

  ///When 'true', the object is instantiated only the first time it is called.
  ///When 'false', the object is instantiated along with the module.
  final bool isLazy;

  BindInject(this.inject, {this.isSingleton = true, this.isLazy = true}) : super(inject, isSingleton: isSingleton, isLazy: isLazy);
}

class BindEmpty extends BindContract<Object> {
  BindEmpty() : super((e) => Object());
}

class SingletonBind<T extends Object> {
  final BindContract<T> bind;
  final T value;

  SingletonBind({required this.bind, required this.value});
}
