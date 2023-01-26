import 'package:bloc/bloc.dart';
import 'package:modular_core/modular_core.dart';

class BlocBind {
  static Bind<T> singleton<T extends BlocBase>(
    T Function(AutoInjector i) factoryFunction, {
    bool export = false,
  }) {
    return Bind.singleton<T>(factoryFunction, onDispose: (bloc) {
      bloc.close();
    }, notifier: (bloc) {
      return bloc.stream;
    });
  }

  static Bind<T> lazySingleton<T extends BlocBase>(
    T Function(AutoInjector i) factoryFunction, {
    bool export = false,
  }) {
    return Bind.lazySingleton<T>(factoryFunction, onDispose: (bloc) {
      bloc.close();
    }, notifier: (bloc) {
      return bloc.stream;
    });
  }

  static Bind<T> factory<T extends BlocBase>(
    T Function(AutoInjector i) factoryFunction, {
    bool export = false,
  }) {
    return Bind.factory<T>(factoryFunction, onDispose: (bloc) {
      bloc.close();
    }, notifier: (bloc) {
      return bloc.stream;
    });
  }

  static Bind<T> instance<T extends BlocBase>(
    T bloc, {
    bool export = false,
  }) {
    return Bind.instance<T>(bloc, onDispose: (bloc) {
      bloc.close();
    }, notifier: (bloc) {
      return bloc.stream;
    });
  }
}
