import 'package:flutter_triple/flutter_triple.dart';
import 'package:modular_triple_bind_example/app/search/domain/entities/result.dart';
import 'package:modular_triple_bind_example/app/search/domain/errors/erros.dart';
import 'package:modular_triple_bind_example/app/search/domain/usecases/search_by_text.dart';

class SearchStore extends Store<List<Result>> {
  final SearchByText searchByText;

  SearchStore(this.searchByText) : super([]);

  void setSearchText(String value) async {
    final result = await searchByText(value);
    result.fold(setError, update);
  }

  @override
  Triple<List<Result>> middleware(Triple<List<Result>> newTriple) {
    if (newTriple.event == TripleEvent.state) {
      if (newTriple.state.isEmpty) {
        return newTriple.copyWith(event: TripleEvent.error, error: EmptyList());
      }
    }

    return newTriple;
  }
}
