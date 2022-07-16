import 'package:mocktail/mocktail.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_modular/src/domain/dtos/route_dto.dart';
import 'package:flutter_modular/src/domain/usecases/get_route.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/mocks.dart';

void main() {
  final service = RouteServiceMock();
  final usecase = GetRouteImpl(service);
  final route = ModularRouteMock();
  const params = RouteParmsDTO(url: '/');
  test('get route', () async {
    when(() => service.getRoute(params)).thenAnswer((_) async => right(route));
    final result = await usecase.call(params);
    expect(result.isRight, true);
  });
}
