import '../../presenters/inject.dart';

class Bind<T extends Object> {
  final T Function(Inject i) inject;

  ///single instance object?
  final bool isSingleton;

  ///When 'true', the object is instantiated only the first time it is called.
  ///When 'false', the object is instantiated along with the module.
  final bool isLazy;

  Bind(this.inject, {this.isSingleton = true, this.isLazy = true}) : assert((isSingleton || isLazy), r"'singleton' can't be false if 'lazy' is also false");

  ///Bind  an already exist 'Instance' of object..
  static Bind<T> instance<T extends Object>(T instance) {
    return Bind<T>((i) => instance, isSingleton: false, isLazy: true);
  }

  ///Bind a 'Singleton' class.
  ///Built together with the module.
  ///The instance will always be the same.
  static Bind<T> singleton<T extends Object>(T Function(Inject i) inject) {
    return Bind<T>(inject, isSingleton: true, isLazy: false);
  }

  ///Bind a 'Lazy Singleton' class.
  ///Built only when called the first time using Modular.get.
  ///The instance will always be the same.
  static Bind<T> lazySingleton<T extends Object>(T Function(Inject i) inject) {
    return Bind<T>(inject, isSingleton: true, isLazy: true);
  }

  ///Bind a factory. Always a new constructor when calling Modular.get
  static Bind<T> factory<T extends Object>(T Function(Inject i) inject) {
    return Bind<T>(inject, isSingleton: false, isLazy: true);
  }
}

class BindInject<T extends Object> extends Bind<T> {
  final T Function(Inject i) inject;

  ///single instance object?
  final bool isSingleton;

  ///When 'true', the object is instantiated only the first time it is called.
  ///When 'false', the object is instantiated along with the module.
  final bool isLazy;

  BindInject(this.inject, {this.isSingleton = true, this.isLazy = true}) : super(inject, isSingleton: isSingleton, isLazy: isLazy);
}

class BindEmpty extends Bind<Object> {
  BindEmpty() : super((e) => Object());
}
