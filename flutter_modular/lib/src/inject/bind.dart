import '../../flutter_modular.dart';

class Bind<T> {
  final T Function(Inject i) inject;

  ///single instance object?
  final bool singleton;

  ///When 'true', the object is instantiated only the first time it is called.
  ///When 'false', the object is instantiated along with the module.
  final bool lazy;

  Bind(this.inject, {this.singleton = true, this.lazy = true})
      : assert((singleton || lazy),
            r"'singleton' can't be false if 'lazy' is also false");

  ///Bind a 'Singleton' class.
  ///Built together with the module.
  ///The instance will always be the same.
  factory Bind.singleton(T Function(Inject i) inject) {
    return Bind(inject, singleton: true, lazy: false);
  }

  ///Bind a 'Lazy Singleton' class.
  ///Built only when called the first time using Modular.get.
  ///The instance will always be the same.
  factory Bind.lazySingleton(T Function(Inject i) inject) {
    return Bind(inject, singleton: true, lazy: true);
  }

  ///Bind a factory. Always a new constructor when calling Modular.get
  factory Bind.factory(T Function(Inject i) inject) {
    return Bind(inject, singleton: false, lazy: false);
  }
}

class BindInject<T> extends Bind<T> {
  final T Function(Inject i) inject;

  ///single instance object?
  final bool singleton;

  ///When 'true', the object is instantiated only the first time it is called.
  ///When 'false', the object is instantiated along with the module.
  final bool lazy;

  BindInject(this.inject, {this.singleton = true, this.lazy = true})
      : super(inject, singleton: singleton, lazy: lazy);
}
