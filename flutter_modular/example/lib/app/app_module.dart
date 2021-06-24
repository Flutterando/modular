import 'package:flutter_modular/flutter_modular.dart';

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
    $SearchStore,
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute, child: (_, __) => SearchPage()),
    ChildRoute(
      '/details',
      child: (_, args) => DetailsPage(result: args.data),
      guards: [
        GuardT('/details'),
      ],
    ),
  ];
}
