import 'package:modular_core/modular_core.dart';
import 'package:modular_core/src/di/bind_context.dart';
import 'package:modular_core/src/di/injector.dart';
import 'package:modular_interfaces/modular_interfaces.dart';
import 'package:test/test.dart';

void main() {
  final instance = InjectorImpl();
  instance.bindContext(MyInjectModule());

  test('get injections', () {
    final bindString = instance.get<String>();
    expect(bindString, 'Jacob');

    final bindDouble = instance.get<double>();
    expect(bindDouble, 0.0);

    final bindInt = instance.get<Map>();
    expect(bindInt, isA<Map>());
  });

  test('throw error when try get bind with export false', () {
    expect(() => instance.get<List>(), throwsA(isException));
  });
}

class MyInjectModule extends BindContextImpl {
  @override
  List<BindContext> get imports => [
        MyInjectModule2(),
      ];

  @override
  List<Bind> get binds => [
        Bind.instance('Jacob'),
        Bind.instance(true),
        Bind.singleton((i) => 0.0),
      ];
}

class MyInjectModule2 extends BindContextImpl {
  @override
  List<Bind> get binds => [
        Bind.singleton<Map>((i) => {}, export: true),
        Bind.singleton<List>((i) => []),
      ];
}
