class Inject<T> {
  ///!!!!NOT RECOMMENDED USE!!!!
  ///Bind has access to the arguments coming from the routes.
  ///If you need specific access, do it through functions.
  @deprecated
  Map<String, dynamic>? params = {};
  final List<Type> typesInRequest;

  Inject({this.params, this.typesInRequest = const []});
}
