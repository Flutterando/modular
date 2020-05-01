import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';

main() {
  setUpAll(() {
    initModule(OtherWidget());
  });

  group("Init ModularWidget", () {
    test('get ObjectTest', () {
      expect(Modular.get<ObjectTest>(), isA<ObjectTest>());
    });
  });
}

class OtherWidget extends WidgetModule {
  @override
  List<Bind> get binds => [
        Bind((i) => ObjectTest()),
        Bind((i) => OtherWidgetNotLazyError(), lazy: false),
      ];

  @override
  Widget get view => throw UnimplementedError();
}

class OtherWidgetNotLazyError {
  OtherWidgetNotLazyError() {
    debugPrint('Not lazy');
  }
}

class ObjectTest {
  ObjectTest() {
    debugPrint('lazy');
  }
}
