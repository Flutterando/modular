import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('instance', () {
    final route = RedirectRoute('/@route', to: 'redirect_route').copyWith();
    expect(route.name, '/@route');
  });
}
