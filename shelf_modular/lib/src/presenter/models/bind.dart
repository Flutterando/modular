import 'package:modular_core/modular_core.dart';

class Bind<T extends Object> extends BindContract<T> {
  Bind(
    T Function(Injector i) factoryFunction, {
    bool isSingleton = true,
    bool isLazy = true,
    bool export = false,
    bool isScoped = true,
  }) : super(factoryFunction, isSingleton: isSingleton, isLazy: isLazy, export: export, isScoped: isScoped);

  ///Bind  an already exist 'Instance' of object..
  static Bind<T> instance<T extends Object>(T instance, {bool export = false}) {
    return Bind<T>((i) => instance, isSingleton: false, isScoped: false, isLazy: true, export: export);
  }

  ///Bind a 'Singleton' class.
  ///Built together with the module.
  ///The instance will always be the same.
  static Bind<T> singleton<T extends Object>(T Function(Injector i) inject, {bool export = false}) {
    return Bind<T>(inject, isSingleton: true, isLazy: false, isScoped: false, export: export);
  }

  ///Create single instance for request.
  static Bind<T> scoped<T extends Object>(T Function(Injector i) inject, {bool export = false}) {
    return Bind<T>(inject, isSingleton: true, isLazy: true, isScoped: true, export: export);
  }

  ///Bind a factory. Always a new constructor when calling Modular.get
  static Bind<T> factory<T extends Object>(T Function(Injector i) inject, {bool export = false}) {
    return Bind<T>(inject, isSingleton: false, isLazy: true, isScoped: false, export: export);
  }
}

class BindInject<T extends Object> extends Bind<T> {
  final T Function(Injector i) inject;

  @override

  ///single instance object?
  final bool isSingleton;

  @override
  final bool isScoped;

  @override

  ///When 'true', the object is instantiated only the first time it is called.
  ///When 'false', the object is instantiated along with the module.
  final bool isLazy;

  BindInject(this.inject, {this.isSingleton = true, this.isLazy = true, this.isScoped = true}) : super(inject, isSingleton: isSingleton, isLazy: isLazy, isScoped: isScoped);
}
