import 'package:example/app/search/domain/errors/erros.dart';
import 'package:example/app/search/domain/entities/result.dart';
import 'package:example/app/search/domain/repositories/search_repository.dart';
import 'package:example/app/search/infra/datasources/search_datasource.dart';
import 'package:dartz/dartz.dart' hide Bind;
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
      if (list == null) {
        return Left<Failure, List<Result>>(DatasourceResultNull());
      }
      if (list.isEmpty) {
        return Left(EmptyList());
      }
      return Right<Failure, List<Result>>(list);
    } catch (e) {
      return Left<Failure, List<Result>>(ErrorSearch());
    }
  }
}
