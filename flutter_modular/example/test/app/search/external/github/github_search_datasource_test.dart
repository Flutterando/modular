import 'package:example/app/search/external/github/github_search_datasource.dart';
import 'package:example/app/search/infra/models/result_model.dart';
import 'package:http/http.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class ClientMock extends Mock implements Client {}

class FakeUri extends Fake implements Uri {}

main() {
  var client = ClientMock();
  var datasource = GithubSearchDatasource(client);

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  test('deve retornar um ResultModel', () async {
    when(() => client.get(any()))
        .thenAnswer((_) async => Response(jsonResponse, 200));

    var result = await datasource.searchText("jacob");
    expect(result, isA<List<ResultModel>>());
  });
}

var jsonResponse = r'''{
  "total_count": 27920,
  "incomplete_results": false,
  "items": [
    {
      "login": "jacob",
      "id": 3121,
      "node_id": "MDQ6VXNlcjMxMjE=",
      "avatar_url": "https://avatars1.githubusercontent.com/u/3121?v=4",
      "gravatar_id": "",
      "url": "https://api.github.com/users/jacob",
      "html_url": "https://github.com/jacob",
      "followers_url": "https://api.github.com/users/jacob/followers",
      "following_url": "https://api.github.com/users/jacob/following{/other_user}",
      "gists_url": "https://api.github.com/users/jacob/gists{/gist_id}",
      "starred_url": "https://api.github.com/users/jacob/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/jacob/subscriptions",
      "organizations_url": "https://api.github.com/users/jacob/orgs",
      "repos_url": "https://api.github.com/users/jacob/repos",
      "events_url": "https://api.github.com/users/jacob/events{/privacy}",
      "received_events_url": "https://api.github.com/users/jacob/received_events",
      "type": "User",
      "site_admin": false,
      "score": 1.0
    }
  ]
}''';
