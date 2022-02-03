import 'package:flutter_modular/src/domain/dtos/route_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Equatable', () {
    expect(const RouteParmsDTO(url: '/'), const RouteParmsDTO(url: '/'));
    expect(const RouteParmsDTO(url: '/').hashCode,
        const RouteParmsDTO(url: '/').hashCode);
  });
}
