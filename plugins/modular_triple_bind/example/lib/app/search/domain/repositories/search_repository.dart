import 'package:modular_triple_bind_example/app/search/domain/entities/result.dart';
import 'package:modular_triple_bind_example/app/search/domain/errors/erros.dart';
import 'package:dartz/dartz.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<Result>>> getUsers(String searchText);
}
