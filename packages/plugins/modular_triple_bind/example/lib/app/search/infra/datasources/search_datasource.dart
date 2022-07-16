import 'package:modular_triple_bind_example/app/search/infra/models/result_model.dart';

abstract class SearchDatasource {
  Future<List<ResultModel>?> searchText(String textSearch);
}
