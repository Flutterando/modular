abstract class SearchEvent {}

class ByTextSearchEvent implements SearchEvent {
  final String text;

  ByTextSearchEvent(this.text);
}
