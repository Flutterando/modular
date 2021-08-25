import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:test/test.dart';

void main() {
  test('Equatable', () {
    expect(RouteParmsDTO(url: '/'), RouteParmsDTO(url: '/'));
    expect(RouteParmsDTO(url: '/').hashCode, RouteParmsDTO(url: '/').hashCode);
  });
}
