import 'package:flutter_modular_test/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_modular/flutter_modular.dart';

class MyModule extends ChildModule {
  final binds = [
    Bind.instance<String>('teste'),
    Bind.instance<bool>(true),
  ];
}

void main() {
  initModule(MyModule());

  test('init Module', () {
    final text = Modular.get<String>();
    expect(text, 'teste');
  });
}
