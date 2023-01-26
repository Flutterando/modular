import 'package:auto_injector/auto_injector.dart';
import 'package:meta/meta.dart';

typedef DisposeCallback<T extends Object> = void Function(T value);
typedef NotifierCallback<T extends Object> = dynamic Function(T value);

abstract class Bind<T extends Object> {
  final Function constructor;

  ///Called in module`s dispose.
  final DisposeCallback<T>? onDispose;

  /// Generate reactive object
  final NotifierCallback<T>? notifier;

  void includeInjector(AutoInjector injector);

  Bind(
    this.constructor, {
    this.onDispose,
    this.notifier,
  });

  static Bind<T> singleton<T extends Object>(
    T Function(AutoInjector i) constructor, {
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  }) {
    return SingletonBind<T>(
      constructor,
      onDispose: onDispose,
      notifier: notifier,
    );
  }

  static Bind<T> lazySingleton<T extends Object>(
    T Function(AutoInjector i) constructor, {
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  }) {
    return LazySingletonBind<T>(
      constructor,
      onDispose: onDispose,
      notifier: notifier,
    );
  }

  static Bind<T> factory<T extends Object>(
    T Function(AutoInjector i) constructor, {
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  }) {
    return FactoryBind<T>(
      constructor,
      onDispose: onDispose,
      notifier: notifier,
    );
  }

  static Bind<T> instance<T extends Object>(
    T instance, {
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  }) {
    return InstanceBind<T>(
      instance,
      onDispose: onDispose,
      notifier: notifier,
    );
  }
}

class SingletonBind<T extends Object> extends Bind<T> {
  SingletonBind(super.constructor, {super.onDispose, super.notifier});

  @override
  void includeInjector(AutoInjector injector) {
    injector.addSingleton<T>(
      constructor,
      onDispose: onDispose,
      notifier: notifier,
    );
  }
}

class LazySingletonBind<T extends Object> extends Bind<T> {
  LazySingletonBind(super.constructor, {super.onDispose, super.notifier});

  @override
  void includeInjector(AutoInjector injector) {
    injector.addLazySingleton<T>(
      constructor,
      onDispose: onDispose,
      notifier: notifier,
    );
  }
}

class FactoryBind<T extends Object> extends Bind<T> {
  FactoryBind(super.constructor, {super.onDispose, super.notifier});

  @override
  void includeInjector(AutoInjector injector) {
    injector.add<T>(
      constructor,
      onDispose: onDispose,
      notifier: notifier,
    );
  }
}

class InstanceBind<T extends Object> extends Bind<T> {
  final T instance;
  InstanceBind(this.instance, {super.onDispose, super.notifier}) : super(() => instance);

  @override
  void includeInjector(AutoInjector injector) {
    injector.addInstance<T>(
      instance,
      onDispose: onDispose,
      notifier: notifier,
    );
  }
}

abstract class AutoBind<T extends Object> extends Bind<T> {
  AutoBind._(super.constructor, {super.onDispose, super.notifier});

  @visibleForTesting
  static AutoBind emptyInstance() => AutoBindEmpty();

  static Bind<T> singleton<T extends Object>(
    Function constructor, {
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  }) {
    return SingletonBind<T>(
      constructor,
      onDispose: onDispose,
      notifier: notifier,
    );
  }

  static Bind<T> lazySingleton<T extends Object>(
    Function constructor, {
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  }) {
    return LazySingletonBind<T>(
      constructor,
      onDispose: onDispose,
      notifier: notifier,
    );
  }

  static Bind<T> factory<T extends Object>(
    Function constructor, {
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  }) {
    return FactoryBind<T>(
      constructor,
      onDispose: onDispose,
      notifier: notifier,
    );
  }

  static Bind<T> instance<T extends Object>(
    T instance, {
    DisposeCallback<T>? onDispose,
    NotifierCallback<T>? notifier,
  }) {
    return InstanceBind<T>(
      instance,
      onDispose: onDispose,
      notifier: notifier,
    );
  }
}

class AutoBindEmpty extends AutoBind<String> {
  AutoBindEmpty() : super._(() => 'String');

  @override
  void includeInjector(AutoInjector injector) {}
}
