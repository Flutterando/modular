import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

final boolBind = Bind((i) => true);
final stringBind = Bind((i) => i(boolBind) ? 'yes' : 'no');

void main() {
  test('get injection bool', () {
    expect(Modular.bind(boolBind), true);
  });

  test('get injection String', () {
    expect(Modular.bind(stringBind), 'yes');
  });

  test('get injection String with override bind', () {
    final boolBindMock = Bind((i) => false);
    Modular.overrideBinds([boolBindMock]);

    expect(Modular.bind(stringBind), 'no');
  });
}
