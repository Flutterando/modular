import 'package:flutter_modular/flutter_modular.dart';
import 'package:http/http.dart' as http;
import 'package:modular_bloc_bind/modular_bloc_bind.dart';

import 'search/domain/repositories/search_repository.dart';
import 'search/domain/usecases/search_by_text.dart';
import 'search/external/github/github_search_datasource.dart';
import 'search/infra/datasources/search_datasource.dart';
import 'search/infra/repositories/search_repository_impl.dart';
import 'search/presenter/blocs/search_bloc.dart';
import 'search/presenter/pages/details_page.dart';
import 'search/presenter/pages/guardt.dart';
import 'search/presenter/pages/search_page.dart';

class AppModule extends Module {
  @override
  final List<Bind> binds = [
    AutoBind.factory<SearchByText>(SearchByTextImpl.new),
    AutoBind.factory<SearchRepository>(SearchRepositoryImpl.new),
    AutoBind.factory<SearchDatasource>(GithubSearchDatasource.new),
    Bind.instance<http.Client>(http.Client()),
    BlocBind.singleton((i) => SearchBloc(i<SearchByText>())),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute, child: (_, __) => const SearchPage()),
    ChildRoute('/details', child: (_, args) => DetailsPage(result: args.data), guards: [GuardT()]),
  ];
}
