import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:http/http.dart' as http;

import 'search/domain/repositories/search_repository.dart';
import 'search/domain/usecases/search_by_text.dart';
import 'search/external/github/github_search_datasource.dart';
import 'search/infra/datasources/search_datasource.dart';
import 'search/infra/repositories/search_repository_impl.dart';
import 'search/presenter/pages/details_page.dart';
import 'search/presenter/pages/guardt.dart';
import 'search/presenter/pages/search_page.dart';
import 'search/presenter/stores/search_store.dart';

class AppModule extends Module {
  AppModule();

  @override
  final List<Bind> binds = [
    Bind.instance<http.Client>(http.Client()),
    Bind.singleton<SearchDatasource>((i) => GithubSearchDatasource(i())),
    Bind.singleton<SearchRepository>((i) => SearchRepositoryImpl(i<SearchDatasource>())),
    AutoBind.singleton<SearchByText>(SearchByTextImpl.new),
    StoreBind.singleton<SearchStore>((i) => SearchStore(i())),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute, child: (_, __) => const SearchPage()),
    ChildRoute('/details', child: (_, args) => DetailsPage(result: args.data), guards: [GuardT()]),
  ];
}

class StoreBind {
  const StoreBind._();

  static Bind<T> singleton<T extends Store>(
    T Function(AutoInjector i) factoryFunction, {
    bool export = false,
  }) {
    return Bind.lazySingleton<T>(
      factoryFunction,
      onDispose: (store) => store.destroy(),
      notifier: (store) {
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
    T Function(AutoInjector i) factoryFunction, {
    bool export = false,
  }) {
    return Bind.lazySingleton<T>(
      factoryFunction,
      onDispose: (bloc) {
        bloc.close();
      },
      notifier: (bloc) {
        return bloc.stream;
      },
    );
  }
}

void main(List<String> args) {
  Function fn = SearchStore.new;
}
