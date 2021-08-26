import 'package:example/src/auth/domain/entities/tokenization.dart';
import 'package:example/src/auth/domain/entities/user.dart';
import 'package:example/src/auth/external/shared/token/token_manager.dart';
import 'package:example/src/auth/infra/datasources/auth_datasource.dart';
import 'package:fpdart/fpdart.dart';
import 'package:postgres/postgres.dart';

class AuthDatasourceImpl implements AuthDatasource {
  final TokenManager tokenManager;

  AuthDatasourceImpl({required this.tokenManager});

  @override
  Future<Tokenization> fromCredentials({required String email, required String password}) async {
    final connection = PostgreSQLConnection('localhost', 5432, 'postgres', username: 'postgres', password: 'postgres');
    await connection.open();
    late Either<dynamic, Tokenization> resultOfConsult;

    try {
      final results = await connection.mappedResultsQuery('SELECT id, name, email FROM users WHERE email=\'$email\' AND password=\'$password\'');
      final user = results.where((element) => element.containsKey('users')).map((e) => e['users']).map((e) => User(id: e!['id'], name: e['name'], email: e['email'])).first;
      final expires = tokenManager.expireTime();
      final token = tokenManager.generateToken({
        'exp': expires,
        'id': user.id,
        'email': user.email,
        'name': user.name,
      });

      resultOfConsult = Right(Tokenization(expires: expires, token: token, user: user));
    } catch (e) {
      resultOfConsult = Left(e);
    } finally {
      await connection.close();
      return resultOfConsult.getOrElse((l) => throw l);
    }
  }
}
