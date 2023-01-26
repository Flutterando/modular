import 'package:flutter/material.dart';
import 'package:modular_core/modular_core.dart';
import 'package:triple/triple.dart';

class LocalNotifier extends ChangeNotifier {
  update() => notifyListeners();
}

class TripleBind {
  static Listenable _generateNotifier(Store store) {
    final notifier = LocalNotifier();
    store.observer(
      onState: (_) => notifier.update(),
      onError: (_) => notifier.update(),
      onLoading: (_) => notifier.update(),
    );

    return notifier;
  }

  static Bind<T> singleton<T extends Store>(T Function(AutoInjector i) factoryFunction) {
    return Bind.singleton<T>(
      factoryFunction,
      onDispose: (store) {
        store.destroy();
      },
      notifier: _generateNotifier,
    );
  }

  static Bind<T> lazySingleton<T extends Store>(
    T Function(AutoInjector i) factoryFunction, {
    bool export = false,
  }) {
    return Bind.lazySingleton<T>(
      factoryFunction,
      onDispose: (store) {
        store.destroy();
      },
      notifier: _generateNotifier,
    );
  }

  static Bind<T> factory<T extends Store>(
    T Function(AutoInjector i) factoryFunction, {
    bool export = false,
  }) {
    return Bind.factory<T>(
      factoryFunction,
      onDispose: (store) {
        store.destroy();
      },
      notifier: _generateNotifier,
    );
  }

  static Bind<T> instance<T extends Store>(
    T store, {
    bool export = false,
  }) {
    return Bind.instance<T>(
      store,
      onDispose: (store) {
        store.destroy();
      },
      notifier: _generateNotifier,
    );
  }
}
