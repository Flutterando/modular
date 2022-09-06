import 'package:shelf_modular/src/domain/dtos/route_dto.dart';
import 'package:test/test.dart';

void main() {
  test('Equatable', () {
    expect(const RouteParmsDTO(url: '/'), const RouteParmsDTO(url: '/'));
    expect(const RouteParmsDTO(url: '/').hashCode, const RouteParmsDTO(url: '/').hashCode);
  });
}
