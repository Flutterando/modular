import 'package:example/src/auth/domain/errors/errors.dart';
import 'package:example/src/auth/domain/entities/tokenization.dart';
import 'package:example/src/auth/domain/repositories/auth_repository.dart';
import 'package:example/src/auth/infra/datasources/auth_datasource.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<Either<AuthException, Tokenization>> fromCredentials(
      {required String email, required String password}) async {
    try {
      final result =
          await datasource.fromCredentials(email: email, password: password);
      return Right(result);
    } on AuthException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<AuthException, Tokenization>> refresh(
      {required String refreshToken}) async {
    try {
      final result = await datasource.refresh(refreshToken: refreshToken);
      return Right(result);
    } on AuthException catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<AuthException, Unit>> checkToken(
      {required String accessToken}) async {
    try {
      await datasource.checkToken(accessToken: accessToken);
      return Right(unit);
    } on AuthException catch (e) {
      return Left(e);
    }
  }
}
