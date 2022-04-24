import 'package:bloc/bloc.dart';
import 'package:example/app/search/domain/usecases/search_by_text.dart';

import '../events/search_event.dart';
import '../states/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchByText searchByText;

  SearchBloc(this.searchByText) : super(ListedSearchState([])) {
    on<ByTextSearchEvent>((event, emit) async {
      final result = await searchByText(event.text);

      result.fold((l) => emit(ErrorState('error')), (r) => emit(ListedSearchState(r)));
    });
  }
}
