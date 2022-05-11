import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:modular_interfaces/src/di/injector.dart';

import 'search/domain/usecases/search_by_text.dart';
import 'search/external/github/github_search_datasource.dart';
import 'search/infra/repositories/search_repository_impl.dart';
import 'package:http/http.dart' as http;

import 'search/presenter/pages/details_page.dart';
import 'search/presenter/pages/guardt.dart';
import 'search/presenter/pages/search_page.dart';
import 'search/presenter/stores/search_store.dart';

class AppModule extends Module {
  @override
  final List<Bind> binds = [
    $SearchByTextImpl,
    $SearchRepositoryImpl,
    $GithubSearchDatasource,
    Bind.instance<http.Client>(http.Client()),
    // Bind<SearchStore>(
    //   (i) => SearchStore(i<SearchByText>()),
    //   isSingleton: true,
    //   isLazy: true,
    //   notifier: (store) {
    //     return Listenable.merge([store.selectState, store.selectLoading, store.selectError]);
    //   },
    //   onDispose: (store) {
    //     store.destroy();
    //   },
    // ),

    StoreBind.singleton((i) => SearchStore(i<SearchByText>())),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute, child: (_, __) => const SearchPage()),
    ChildRoute('/details',
        child: (_, args) => DetailsPage(result: args.data), guards: [GuardT()]),
  ];
}

class StoreBind {
  const StoreBind._();

  static Bind<T> singleton<T extends Store>(
    T Function(Injector<dynamic> i) factoryFunction, {
    bool export = false,
  }) {
    return Bind<T>(
      factoryFunction,
      export: export,
      isLazy: false,
      onDispose: (store) => store.destroy(),
      selector: (store) {
        final notifier = ChangeNotifier();
        store.observer(
          onState: (_) => notifier.notifyListeners(),
          onError: (_) => notifier.notifyListeners(),
          onLoading: (_) => notifier.notifyListeners(),
        );
        return notifier;
      },
    );
  }
}

class BlocBind {
  static Bind<T> singleton<T extends Bloc>(
    T Function(Injector<dynamic> i) factoryFunction, {
    bool export = false,
  }) {
    return Bind<T>(factoryFunction, export: true, isLazy: false,
        onDispose: (bloc) {
      bloc.close();
    }, selector: (bloc) {
      return bloc.stream;
    });
  }
}
