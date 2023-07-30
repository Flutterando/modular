import '../../domain/entities/result.dart';

abstract class SearchState {
  T when<T>({
    T Function(ListedSearchState state)? onState,
    T Function(ErrorState error)? onError,
    T Function()? onLoading,
  });
}

class LoadingState implements SearchState {
  @override
  T when<T>({
    T Function(ListedSearchState state)? onState,
    T Function(ErrorState error)? onError,
    T Function()? onLoading,
  }) {
    return onLoading!();
  }
}

class ErrorState implements SearchState {
  final String message;

  ErrorState(this.message);

  @override
  T when<T>({
    T Function(ListedSearchState state)? onState,
    T Function(ErrorState error)? onError,
    T Function()? onLoading,
  }) {
    return onError!(this);
  }
}

class ListedSearchState implements SearchState {
  final List<Result> list;

  ListedSearchState(this.list);

  @override
  T when<T>({
    T Function(ListedSearchState state)? onState,
    T Function(ErrorState error)? onError,
    T Function()? onLoading,
  }) {
    return onState!(this);
  }
}
