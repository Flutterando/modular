import 'package:flutter_triple/flutter_triple.dart';
import 'package:modular_triple_bind_example/app/core/dartz_adapter/dartz_adapter.dart';
import 'package:modular_triple_bind_example/app/search/domain/entities/result.dart';
import 'package:modular_triple_bind_example/app/search/domain/errors/erros.dart';
import 'package:modular_triple_bind_example/app/search/domain/usecases/search_by_text.dart';

class SearchStore extends NotifierStore<Failure, List<Result>> {
  final SearchByText searchByText;

  SearchStore(this.searchByText) : super([]);

  void setSearchText(String value) {
    executeEither(
      () => DartzEitherAdapter.adapter(searchByText(value)),
      delay: const Duration(milliseconds: 500),
    );
  }

  @override
  Triple<Failure, List<Result>> middleware(Triple<Failure, List<Result>> newTriple) {
    if (newTriple.event == TripleEvent.state) {
      if (newTriple.state.isEmpty) {
        return newTriple.copyWith(event: TripleEvent.error, error: EmptyList());
      }
    }

    return newTriple;
  }
}
