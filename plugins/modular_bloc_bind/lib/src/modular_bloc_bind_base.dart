import 'package:bloc/bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:modular_interfaces/modular_interfaces.dart';

class BlocBind {
  static Bind<T> singleton<T extends BlocBase>(
    T Function(Injector<dynamic> i) factoryFunction, {
    bool export = false,
  }) {
    return Bind<T>(factoryFunction, export: export, isLazy: false, onDispose: (bloc) {
      bloc.close();
    }, selector: (bloc) {
      return bloc.stream;
    });
  }

  static Bind<T> lazySingleton<T extends BlocBase>(
    T Function(Injector<dynamic> i) factoryFunction, {
    bool export = false,
  }) {
    return Bind<T>(factoryFunction, export: export, isLazy: true, onDispose: (bloc) {
      bloc.close();
    }, selector: (bloc) {
      return bloc.stream;
    });
  }

  static Bind<T> factory<T extends BlocBase>(
    T Function(Injector<dynamic> i) factoryFunction, {
    bool export = false,
  }) {
    return Bind<T>(factoryFunction, export: export, isLazy: true, isSingleton: false, onDispose: (bloc) {
      bloc.close();
    }, selector: (bloc) {
      return bloc.stream;
    });
  }

  static Bind<T> instance<T extends BlocBase>(
    T bloc, {
    bool export = false,
  }) {
    return Bind<T>((i) => bloc, export: export, isLazy: true, isSingleton: false, onDispose: (bloc) {
      bloc.close();
    }, selector: (bloc) {
      return bloc.stream;
    });
  }
}
