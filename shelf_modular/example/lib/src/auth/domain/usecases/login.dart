import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:shelf_modular_example/src/auth/domain/entities/tokenization.dart';
import 'package:shelf_modular_example/src/auth/domain/errors/errors.dart';
import 'package:shelf_modular_example/src/auth/domain/repositories/auth_repository.dart';

abstract class Login {
  Future<Either<AuthException, Tokenization>> call({required String credentials});
}

class LoginImpl implements Login {
  final AuthRepository repository;

  LoginImpl(this.repository);

  @override
  Future<Either<AuthException, Tokenization>> call({required String credentials}) async {
    final decoded = String.fromCharCodes(base64Decode(credentials));
    final splited = decoded.split(':');
    final email = splited[0];
    final password = splited[1];

    return await repository.fromCredentials(email: email, password: password);
  }
}
