import 'package:search/app/search/domain/entities/result.dart';
import 'package:search/app/search/domain/errors/erros.dart';
import 'package:dartz/dartz.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<Result>>> getUsers(String searchText);
}
