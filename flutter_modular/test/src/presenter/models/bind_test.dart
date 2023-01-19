import 'package:flutter_modular/src/presenter/models/bind.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modular_core/modular_core.dart';

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
    final bind = Bind.lazySingleton((i) => 'instance');
    expect(bind.isSingleton, true);
    expect(bind.isLazy, true);
  });

  test('AsyncBind', () async {
    final asyncBind = AsyncBind((i) async => 'instance');
    final bind = await asyncBind.convertToBind();
    expect(bind.isSingleton, true);
    expect(bind.isLazy, true);
  });

  test('BindInject', () async {
    final bind = BindInject((i) => 'instance');
    expect(bind.isSingleton, true);
    expect(bind.isLazy, true);
  });
  test('copyWith', () async {
    final bind = BindInject((i) => 'instance');
    expect(bind.copyWith(), isA<Bind>());
  });

  test('copyWith asyncBind', () async {
    final asyncBind = AsyncBind((i) async => 'instance');
    expect(asyncBind.copyWith(), isA<AsyncBindContract>());
  });
}
