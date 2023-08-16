import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf_modular_example/src/auth/external/shared/token/token_manager.dart';
import 'package:shelf_modular_example/src/auth/presenter/auth_resource.dart';

import 'domain/usecases/check_token.dart';
import 'domain/usecases/login.dart';
import 'domain/usecases/refresh_token.dart';
import 'external/postgres/datasources/postgres_auth_datasource.dart';
import 'external/postgres/datasources/postgres_connect.dart';
import 'external/shared/redis/redis_service.dart';
import 'infra/repositories/auth_repository.dart';

class AuthModule extends Module {
  @override
  void binds(i) {
    //external
    i.addSingleton(RedisService.new);
    i.addSingleton(PostgresConnect.new);
    i.add(TokenManager.new);
    i.add(AuthDatasourceImpl.new);
    //infra
    i.add(AuthRepositoryImpl.new);
    //domain
    i.add(LoginImpl.new);
    i.add(RefreshTokenImpl.new);
    i.add(CheckTokenImpl.new);
  }

  @override
  void routes(r) {
    r.resource(AuthResource());
  }
}
