import 'package:bloc/bloc.dart';
import 'package:example/app/search/domain/usecases/search_by_text.dart';

import '../events/search_event.dart';
import '../states/search_state.dart';
import 'package:stream_transform/stream_transform.dart';

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchByText searchByText;

  SearchBloc(this.searchByText) : super(ListedSearchState([])) {
    on<ByTextSearchEvent>(
      (event, emit) async {
        emit(LoadingState());
        final result = await searchByText(event.text);

        result.fold((l) => emit(ErrorState('error')), (r) => emit(ListedSearchState(r)));
      },
      transformer: debounce(const Duration(milliseconds: 300)),
    );
  }
}
