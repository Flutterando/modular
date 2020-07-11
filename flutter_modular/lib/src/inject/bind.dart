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
