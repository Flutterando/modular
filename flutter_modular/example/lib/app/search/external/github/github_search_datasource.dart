import 'dart:convert';

import 'package:search/app/search/infra/datasources/search_datasource.dart';
import 'package:search/app/search/infra/models/result_model.dart';
import 'package:http/http.dart';
import 'package:flutter_modular/flutter_modular.dart';
part 'github_search_datasource.g.dart';

@Injectable(singleton: false)
class GithubSearchDatasource implements SearchDatasource {
  final Client client;

  GithubSearchDatasource(this.client);

  @override
  Future<List<ResultModel>?> searchText(String textSearch) async {
    var result = await this.client.get("https://api.github.com/search/users?q=${textSearch.trim().replaceAll(' ', '+')}");
    if (result.statusCode == 200) {
      final json = jsonDecode(result.body);
      print('execute datasource');
      var jsonList = json['items'] as List;
      var list = jsonList.map((item) => ResultModel(name: '', nickname: item['login'], image: item['avatar_url'], url: item['url'])).toList();
      return list;
    } else {
      throw Exception();
    }
  }
}
