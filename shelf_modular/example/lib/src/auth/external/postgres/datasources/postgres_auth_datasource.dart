import 'package:example/src/auth/domain/entities/tokenization.dart';
import 'package:example/src/auth/external/errors/errors.dart';
import 'package:example/src/auth/external/shared/token/token_manager.dart';
import 'package:example/src/auth/infra/datasources/auth_datasource.dart';
import 'package:fpdart/fpdart.dart';
import 'package:postgres/postgres.dart';
import 'package:redis_dart/redis_dart.dart';
import 'package:uuid/uuid.dart';

class AuthDatasourceImpl implements AuthDatasource {
  final TokenManager tokenManager;

  AuthDatasourceImpl({required this.tokenManager});

  @override
  Future<Tokenization> fromCredentials({required String email, required String password}) async {
    final connection = PostgreSQLConnection('localhost', 5432, 'postgres', username: 'postgres', password: 'postgres');
    await connection.open();
    final redis = await RedisClient.connect('localhost');

    late Either<dynamic, Tokenization> resultOfConsult;

    try {
      final results = await connection.mappedResultsQuery('SELECT id FROM users WHERE email=\'$email\' AND password=\'$password\'');
      final userList = results.where((element) => element.containsKey('users')).map((e) => e['users']);
      if (userList.isEmpty) {
        throw NotAuthorized('acesso negado');
      }
      final userMap = userList.first;
      final refreshToken = Uuid().v1();
      final tokenization = _generateTokenization(userMap!, refreshToken);
      // this is a HSET command
      await redis.setMap(refreshToken, userMap);
      await redis.expireAt(refreshToken, DateTime.now().add(Duration(seconds: 60)));

      resultOfConsult = Right(tokenization);
    } on Error catch (e) {
      resultOfConsult = Left(e);
    } on Exception catch (e) {
      resultOfConsult = Left(e);
    } finally {
      await connection.close();
      await redis.close();
      return resultOfConsult.getOrElse((l) => throw l);
    }
  }

  Tokenization _generateTokenization(Map claims, String newRefreshToken) {
    final expiresIn = const Duration(seconds: 30);

    final accessToken = tokenManager.generateToken({
      'exp': tokenManager.expireTime(expiresIn),
      ...claims,
    });
    final tokenization = Tokenization(expiresIn: expiresIn.inSeconds, accessToken: accessToken, refreshToken: newRefreshToken);
    return tokenization;
  }

  @override
  Future<Tokenization> refresh({required String refreshToken}) async {
    late Either<dynamic, Tokenization> resultOfConsult;
    final redis = await RedisClient.connect('localhost');
    try {
      final claims = await redis.getMap(refreshToken);
      final userIdMap = (claims.value as Map).cast<String, dynamic>();
      if (userIdMap.isEmpty) {
        throw NotAuthorized('Revoked token');
      }
      await redis.delete(refreshToken);
      refreshToken = Uuid().v1();
      await redis.setMap(refreshToken, userIdMap);
      await redis.expireAt(refreshToken, DateTime.now().add(Duration(seconds: 60)));
      final tokenization = _generateTokenization(userIdMap, refreshToken);
      resultOfConsult = Right(tokenization);
    } on Error catch (e) {
      resultOfConsult = Left(e);
    } on Exception catch (e) {
      resultOfConsult = Left(e);
    } finally {
      await redis.close();
      return resultOfConsult.getOrElse((l) => throw l);
    }
  }

  @override
  Future<void> checkToken({required String accessToken}) async {
    await tokenManager.validateToken(accessToken);
  }
}
