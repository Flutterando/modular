import 'package:flutter_modular/src/presenter/models/bind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bind instance', () {
    final bind = Bind.instance('instance');
    expect(bind.isSingleton, false);
    expect(bind.isLazy, true);
  });

  test('bind singleton', () {
    final bind = Bind.singleton((i) => 'instance');
    expect(bind.isSingleton, true);
    expect(bind.isLazy, false);
  });

  test('bind factory', () {
    final bind = Bind.factory((i) => 'instance');
    expect(bind.isSingleton, false);
    expect(bind.isLazy, true);
  });

  test('bind scoped', () {
    final bind = Bind.scoped((i) => 'instance');
    expect(bind.isSingleton, true);
    expect(bind.isScoped, true);
    expect(bind.isLazy, true);
  });
}
