import 'package:search/app/search/domain/errors/erros.dart';
import 'package:search/app/search/domain/entities/result.dart';
import 'package:search/app/search/domain/repositories/search_repository.dart';
import 'package:search/app/search/infra/datasources/search_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_modular/flutter_modular.dart';
part 'search_repository_impl.g.dart';

@Injectable(singleton: false)
class SearchRepositoryImpl implements SearchRepository {
  final SearchDatasource datasource;

  SearchRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, List<Result>>> getUsers(String searchText) async {
    try {
      final list = await datasource.searchText(searchText);
      return list == null ? Left<Failure, List<Result>>(DatasourceResultNull()) : Right<Failure, List<Result>>(list);
    } catch (e) {
      return Left<Failure, List<Result>>(ErrorSearch());
    }
  }
}
