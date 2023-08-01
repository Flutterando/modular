import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular_example/app/app_module.dart';
import 'package:flutter_modular_example/app/search/domain/usecases/search_by_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class ClientMock extends Mock implements Client {}

class ResponseMock extends Mock implements Response {}

void main() {
  final client = ClientMock();

  Modular.bindModule(AppModule());
  Modular.replaceInstance<Client>(client);

  setUpAll(() {
    registerFallbackValue(Uri.parse(''));
  });

  tearDown(() => reset(client));

  test('app module ...', () async {
    final response = ResponseMock();
    when(() => response.statusCode).thenReturn(200);
    when(() => response.body).thenReturn('[]');
    when(() => client.get(any())).thenAnswer((_) async => response);

    final result = await Modular.get<SearchByText>()('1323');

    expect(result.isRight(), true);
  });
}
