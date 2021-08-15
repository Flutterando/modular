import 'dart:async';

import 'injector.dart';

class Bind<T extends Object> {
  final T Function(Inject i) factoryFunction;

  ///single instance object?
  final bool isSingleton;

  ///export bind for others modules
  final bool export;

  ///When 'true', the object is instantiated only the first time it is called.
  ///When 'false', the object is instantiated along with the module.
  final bool isLazy;

  Bind(this.factoryFunction, {this.isSingleton = true, this.isLazy = true, this.export = false}) : assert((isSingleton || isLazy), r"'singleton' can't be false if 'lazy' is also false");

  ///Bind  an already exist 'Instance' of object..
  static Bind<T> instance<T extends Object>(T instance, {bool export = false}) {
    return Bind<T>((i) => instance, isSingleton: false, isLazy: true, export: export);
  }

  ///Bind a 'Singleton' class.
  ///Built together with the module.
  ///The instance will always be the same.
  static Bind<T> singleton<T extends Object>(T Function(Inject i) inject, {bool export = false}) {
    return Bind<T>(inject, isSingleton: true, isLazy: false, export: export);
  }

  ///Bind a 'Lazy Singleton' class.
  ///Built only when called the first time using Modular.get.
  ///The instance will always be the same.
  static Bind<T> lazySingleton<T extends Object>(T Function(Inject i) inject, {bool export = false}) {
    return Bind<T>(inject, isSingleton: true, isLazy: true, export: export);
  }

  ///Bind a factory. Always a new constructor when calling Modular.get
  static Bind<T> factory<T extends Object>(T Function(Inject i) inject, {bool export = false}) {
    return Bind<T>(inject, isSingleton: false, isLazy: true, export: export);
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

class AsyncBind<T extends Object> extends Bind<Future<T>> {
  final Future<T> Function(Inject i) asyncInject;

  ///export bind for others modules
  final bool export;

  AsyncBind(this.asyncInject, {this.export = false}) : super(asyncInject, export: export);

  Future<T> resolveAsyncBind() async {
    final bind = await asyncInject(Inject.instance);
    return bind;
  }

  Future<Bind<T>> converToAsyncBind() async {
    final bindValue = await resolveAsyncBind();
    return Bind<T>((i) => bindValue, export: export);
  }
}
