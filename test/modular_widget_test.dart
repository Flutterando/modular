import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';

main() {
  setUpAll(() {});

  group("Init ModularWidget", () {
    test('ModularWidget', () async {});
  });
}

class OtherWidget extends ModuleWidget {
  @override
  List<Bind> get binds => throw UnimplementedError();

  @override
  Widget get view => throw UnimplementedError();
}
