import 'package:fpdart/fpdart.dart';
import 'package:shelf_modular_example/src/auth/domain/entities/tokenization.dart';
import 'package:shelf_modular_example/src/auth/domain/errors/errors.dart';

abstract class AuthRepository {
  Future<Either<AuthException, Tokenization>> fromCredentials({required String email, required String password});
  Future<Either<AuthException, Tokenization>> refresh({required String refreshToken});
  Future<Either<AuthException, Unit>> checkToken({required String accessToken});
}
