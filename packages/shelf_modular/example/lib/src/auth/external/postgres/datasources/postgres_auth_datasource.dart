import 'package:example/src/auth/domain/entities/tokenization.dart';
import 'package:example/src/auth/external/errors/errors.dart';
import 'package:example/src/auth/external/shared/redis/redis_service.dart';
import 'package:example/src/auth/external/shared/token/token_manager.dart';
import 'package:example/src/auth/infra/datasources/auth_datasource.dart';
import 'package:uuid/uuid.dart';

import 'postgres_connect.dart';

class AuthDatasourceImpl implements AuthDatasource {
  final TokenManager tokenManager;
  final IRedisService redis;
  final IPostgresConnect pg;

  AuthDatasourceImpl(
      {required this.tokenManager, required this.redis, required this.pg});

  @override
  Future<Tokenization> fromCredentials(
      {required String email, required String password}) async {
    final connection = await pg.connection;
    final results = await connection.mappedResultsQuery(
      'SELECT id FROM users WHERE email=@email AND password=@password',
      substitutionValues: {
        'email': email,
        'password': password,
      },
    );
    final userList = results
        .where((element) => element.containsKey('users'))
        .map((e) => e['users']!);

    if (userList.isEmpty) {
      throw NotAuthorized('acesso negado');
    }

    final userMap = userList.first;
    final refreshToken = Uuid().v1();
    final tokenization = _generateTokenization(userMap, refreshToken);
    await redis.setMap(refreshToken, userMap, Duration(seconds: 60));

    return tokenization;
  }

  @override
  Future<Tokenization> refresh({required String refreshToken}) async {
    final userIdMap = await redis.getMap(refreshToken);
    if (userIdMap.isEmpty) {
      throw NotAuthorized('Revoked token');
    }

    await redis.delete(refreshToken);
    refreshToken = Uuid().v1();
    await redis.setMap(refreshToken, userIdMap, Duration(seconds: 60));
    final tokenization = _generateTokenization(userIdMap, refreshToken);
    return tokenization;
  }

  @override
  Future<void> checkToken({required String accessToken}) async {
    await tokenManager.validateToken(accessToken);
  }

  Tokenization _generateTokenization(Map claims, String newRefreshToken) {
    final expiresIn = const Duration(seconds: 30);

    final accessToken = tokenManager.generateToken({
      'exp': tokenManager.expireTime(expiresIn),
      ...claims,
    });

    final tokenization = Tokenization(
        expiresIn: expiresIn.inSeconds,
        accessToken: accessToken,
        refreshToken: newRefreshToken);
    return tokenization;
  }
}
