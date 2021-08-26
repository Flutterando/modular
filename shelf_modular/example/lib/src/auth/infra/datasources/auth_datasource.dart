import 'package:example/src/auth/domain/entities/tokenization.dart';

abstract class AuthDatasource {
  Future<Tokenization> fromCredentials({required String email, required String password});
}
