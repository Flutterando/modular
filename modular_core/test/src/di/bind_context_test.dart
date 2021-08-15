import 'package:modular_core/modular_core.dart';
import 'package:test/test.dart';

void main() {
  Injector.instance.bindContext(MyInjectModule());

  test('get injections', () {
    final bindString = Injector.instance.get<String>();
    expect(bindString, 'Jacob');

    final bindDouble = Injector.instance.get<double>();
    expect(bindDouble, 0.0);

    final bindInt = Injector.instance.get<Map>();
    expect(bindInt, isA<Map>());
  });

  test('throw error when try get bind with export false', () {
    expect(() => Injector.instance.get<List>(), throwsA(isException));
  });
}

class MyInjectModule extends BindContext {
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

class MyInjectModule2 extends BindContext {
  @override
  List<Bind> get binds => [
        Bind.singleton<Map>((i) => {}, export: true),
        Bind.singleton<List>((i) => []),
      ];
}
