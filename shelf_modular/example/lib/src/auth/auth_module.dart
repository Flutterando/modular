import 'package:example/src/auth/external/shared/token/token_manager.dart';
import 'package:example/src/auth/presenter/auth_resource.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'domain/usecases/login.dart';
import 'external/postgres/datasources/postgres_auth_datasource.dart';
import 'infra/repositories/auth_repository.dart';

class AuthModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        //external
        Bind.factory((i) => TokenManager()),
        Bind.factory((i) => AuthDatasourceImpl(tokenManager: i())),
        //infra
        Bind.factory((i) => AuthRepositoryImpl(i())),
        //domain
        Bind.factory((i) => LoginImpl(i())),
      ];

  @override
  List<ModularRoute> get routes => [
        Route.resource('/', resource: AuthResource()),
      ];
}
