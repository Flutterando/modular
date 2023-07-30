import 'package:fpdart/fpdart.dart';
import 'package:shelf_modular_example/src/auth/domain/entities/tokenization.dart';
import 'package:shelf_modular_example/src/auth/domain/errors/errors.dart';
import 'package:shelf_modular_example/src/auth/domain/repositories/auth_repository.dart';

abstract class RefreshToken {
  Future<Either<AuthException, Tokenization>> call(
      {required String refreshToken});
}

class RefreshTokenImpl implements RefreshToken {
  final AuthRepository repository;

  RefreshTokenImpl(this.repository);

  @override
  Future<Either<AuthException, Tokenization>> call(
      {required String refreshToken}) async {
    return await repository.refresh(refreshToken: refreshToken);
  }
}
