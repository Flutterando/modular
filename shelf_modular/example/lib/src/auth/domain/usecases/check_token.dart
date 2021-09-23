import 'package:example/src/auth/domain/errors/errors.dart';
import 'package:example/src/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

abstract class CheckToken {
  Future<Either<AuthException, Unit>> call({required String accessToken});
}

class CheckTokenImpl implements CheckToken {
  final AuthRepository repository;

  CheckTokenImpl(this.repository);

  @override
  Future<Either<AuthException, Unit>> call(
      {required String accessToken}) async {
    return await repository.checkToken(accessToken: accessToken);
  }
}
