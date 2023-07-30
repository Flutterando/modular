import 'package:modular_bloc_bind_example/app/search/domain/entities/result.dart';
import 'package:modular_bloc_bind_example/app/search/domain/errors/erros.dart';
import 'package:modular_bloc_bind_example/app/search/domain/repositories/search_repository.dart';
import 'package:dartz/dartz.dart' hide Bind;

mixin SearchByText {
  Future<Either<Failure, List<Result>>> call(String textSearch);
}

class SearchByTextImpl implements SearchByText {
  final SearchRepository repository;

  SearchByTextImpl(this.repository);

  @override
  Future<Either<Failure, List<Result>>> call(String? textSearch) async {
    if (textSearch?.isEmpty ?? true) {
      return Left(InvalidSearchText());
    }
    return await repository.getUsers(textSearch!);
  }
}
