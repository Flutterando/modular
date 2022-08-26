import 'package:shelf_modular/shelf_modular.dart';
import 'package:test/test.dart';

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

  test('BindInject', () async {
    final bind = BindInject((i) => 'instance');
    expect(bind.isSingleton, true);
    expect(bind.isLazy, true);
  });
  test('CopyWith', () async {
    final bind = BindInject((i) => 'instance');
    final otherBind = bind.copyWith();
    expect(otherBind != bind, true);
  });
}
