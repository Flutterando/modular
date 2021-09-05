import 'package:example/src/auth/domain/entities/tokenization.dart';
import 'package:example/src/auth/domain/errors/errors.dart';
import 'package:fpdart/fpdart.dart';

abstract class AuthRepository {
  Future<Either<AuthException, Tokenization>> fromCredentials(
      {required String email, required String password});
  Future<Either<AuthException, Tokenization>> refresh(
      {required String refreshToken});
  Future<Either<AuthException, Unit>> checkToken({required String accessToken});
}
