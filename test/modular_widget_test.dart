import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';

main() {
  setUpAll(() {
    initModule(OtherWidget());
  });

  group("Init ModularWidget", () {
    test('ModularWidget', () {
      expect(Modular.get<ObjectTest>(), isA<ObjectTest>());
    });
  });
}

class OtherWidget extends ModuleWidget {
  @override
  List<Bind> get binds => [
        Bind((i) => ObjectTest()),
      ];

  @override
  Widget get view => throw UnimplementedError();
}

class ObjectTest {}
