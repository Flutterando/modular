import 'package:modular_core/modular_core.dart';

class TrackerInjector implements Injector {
  final Injector _global;
  late final AutoInjector _local;

  AutoInjector get local => _local;

  TrackerInjector(this._global, String tag) {
    _local = AutoInjector(tag: tag);
  }

  @override
  void add<T>(Function constructor, {BindConfig<T>? config, String? key}) {
    _local.add(constructor, config: config, key: key);
  }

  @override
  void addInstance<T>(T instance, {BindConfig<T>? config, String? key}) {
    _local.addInstance(instance, config: config, key: key);
  }

  @override
  void addLazySingleton<T>(
    Function constructor, {
    BindConfig<T>? config,
    String? key,
  }) {
    _local.addLazySingleton(constructor, config: config, key: key);
  }

  @override
  void addSingleton<T>(
    Function constructor, {
    BindConfig<T>? config,
    String? key,
  }) {
    _local.addSingleton(constructor, config: config, key: key);
  }

  @override
  T call<T>({ParamTransform? transform, String? key}) {
    return _global(transform: transform, key: key);
  }

  @override
  T get<T>({ParamTransform? transform, String? key}) {
    return _global.get(transform: transform, key: key);
  }

  @override
  dynamic getNotifier<T>({String? key}) {
    return _global.getNotifier(key: key);
  }
}
