import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_modular/src/presenter/utils/handlers.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

class RequestMock extends Mock implements Request {}

void main() {
  test('HandlerWithlessParams', () {
    expect(
        applyHandler(
          () => Response.ok(''),
          request: RequestMock(),
          arguments: ModularArguments.empty(),
          injector: InjectorMock(),
        ),
        isNotNull);
  });

  test('Handle', () {
    expect(
        applyHandler(
          (request) => Response.ok(''),
          request: RequestMock(),
          arguments: ModularArguments.empty(),
          injector: InjectorMock(),
        ),
        isNotNull);
  });
}
