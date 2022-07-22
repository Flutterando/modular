import 'package:example/src/auth/external/shared/token/token_manager.dart';
import 'package:example/src/auth/presenter/auth_resource.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'domain/usecases/check_token.dart';
import 'domain/usecases/login.dart';
import 'domain/usecases/refresh_token.dart';
import 'external/postgres/datasources/postgres_auth_datasource.dart';
import 'external/postgres/datasources/postgres_connect.dart';
import 'external/shared/redis/redis_service.dart';
import 'infra/repositories/auth_repository.dart';

class AuthModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        //external
        Bind.scoped((i) => RedisService()),
        Bind.scoped((i) => PostgresConnect()),
        Bind.factory((i) => TokenManager()),
        Bind.factory(
            (i) => AuthDatasourceImpl(tokenManager: i(), redis: i(), pg: i())),
        //infra
        Bind.factory((i) => AuthRepositoryImpl(i())),
        //domain
        Bind.factory((i) => LoginImpl(i())),
        Bind.factory((i) => RefreshTokenImpl(i())),
        Bind.factory((i) => CheckTokenImpl(i())),
      ];

  @override
  List<ModularRoute> get routes => [
        Route.resource(AuthResource()),
      ];
}
