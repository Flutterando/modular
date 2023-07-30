import 'package:dartz/dartz.dart';
import 'package:flutter_modular_example/app/search/domain/entities/result.dart';
import 'package:flutter_modular_example/app/search/domain/errors/erros.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<Result>>> getUsers(String searchText);
}
