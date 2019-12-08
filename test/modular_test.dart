import 'package:flutter_test/flutter_test.dart';

import 'package:modular/modular.dart';

import 'app/app_module.dart';

void main() {
  setUpAll(() {
    Modular.init(AppModule());
  });

  group("Group router", () {
    test('Test Get Router', () {
      expect(Modular.selectRoute("."), isA<Router>());
    });
    test('Test Get module Router', () {
      expect(Modular.selectRoute("home."), isA<Router>());
      expect(Modular.selectRoute(".home."), isA<Router>());
    });
    test('Test Get module sub Router', () {
      expect(Modular.selectRoute(".home.list"), isA<Router>());
    });

    test('router empty', () {
      expect(() => Modular.selectRoute(""), throwsException);
    });
  });

}
