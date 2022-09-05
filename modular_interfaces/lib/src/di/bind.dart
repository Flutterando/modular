import 'injector.dart';

///Abstract class [BindContract]
///Responsible for the bind contract
abstract class BindContract<T extends Object> {
  ///[factoryFunction] variable type [Function]
  final T Function(Injector i) factoryFunction;

  ///[bindType] variable type [Type]
  Type get bindType => T;

  ///single instance
  final bool isSingleton;

  /// flag for indicate serialization
  final bool alwaysSerialized;

  ///create single instance for request
  final bool isScoped;

  ///export bind for others modules
  ///This bind can only be accessed when imported by a module.
  final bool export;

  ///When 'true', the object is instantiated only the first time it is called.
  ///When 'false', the object is instantiated along with the module.
  final bool isLazy;

  ///Called in module`s dispose.
  final void Function(T value)? onDispose;

  /// Generate reactive object
  final dynamic Function(T value)? selector;

  ///Constructor for [BindContract]
  BindContract(
    this.factoryFunction, {
    this.isSingleton = true,
    this.isLazy = true,
    this.export = false,
    this.isScoped = false,
    this.alwaysSerialized = false,
    this.onDispose,
    this.selector,
  }) : assert(
          isSingleton || isLazy,
          "'singleton' can't be false if 'lazy' is also false",
        );

  ///Copy the [BindContract] object into another memory reference
  BindContract<T> copyWith({
    T Function(Injector i)? factoryFunction,
    bool? isSingleton,
    bool? isLazy,
    bool? export,
    bool? isScoped,
    bool? alwaysSerialized,
    void Function(T value)? onDispose,
    dynamic Function(T value)? selector,
  });

  ///Creates a [cast] for an object
  BindContract<E> cast<E extends Object>();

  ///Creates a selector function where the object received will be generated
  ///as a reactive object
  dynamic onSelectorFunc(Object o) => selector?.call(o as T);

  ///Creates a dispose function where the object received will be disposed
  dynamic onDisposeFunc(Object o) => onDispose?.call(o as T);
}

/// For empty instance binds.
class BindEmpty extends BindContract<Object> {
  /// [BindEmpty] constructor
  BindEmpty() : super((e) => Object());

  @override
  BindContract<E> cast<E extends Object>() {
    throw UnimplementedError();
  }

  @override
  BindContract<Object> copyWith({
    Object Function(Injector i)? factoryFunction,
    bool? isSingleton,
    bool? isLazy,
    bool? export,
    bool? isScoped,
    bool? alwaysSerialized,
    void Function(Object value)? onDispose,
    Function(Object value)? selector,
  }) {
    throw UnimplementedError();
  }
}

///Creates and entry for bind
class BindEntry<T extends Object> {
  ///[bind] variable type [BindContract]
  final BindContract<T> bind;

  ///[value] variable type [T]
  final T value;

  ///[BindEntry] constructor
  BindEntry({required this.bind, required this.value});

  ///Returns a [BindEntry] with the [bind] and [value] casts a [Object]
  BindEntry<E> cast<E extends Object>() {
    return BindEntry<E>(bind: bind.cast<E>(), value: value as E);
  }

  ///Disposes the object [value]
  void dispose() {
    bind.onDisposeFunc(value);
  }
}
