import 'package:modular_test/modular_test.dart' as modular_test;
import 'package:test/test.dart';

import 'package:modular_core/modular_core.dart';

abstract class IRepo {
  String get name;
}

class RepoImpl1 implements IRepo {
  @override
  String get name => 'RepoImpl1';
}

class RepoImpl2 implements IRepo {
  @override
  String get name => 'RepoImpl2';
}

class MyModule extends RouteContextImpl {
  final binds = [
    _Bind<String>((i) => 'teste'),
    _Bind<bool>((i) => true),
    _Bind<IRepo>((i) => RepoImpl1()),
  ];
}

void main() {
  final repo = RepoImpl2();

  modular_test.initModules(
    [MyModule()],
    replaceBinds: [
      _Bind<bool>((i) => false),
      _Bind<IRepo>((i) => repo),
    ],
  );

  test('init Module', () {
    final text = ModularTracker.injector.get<String>();
    expect(text, 'teste');
  });

  test('replace binds', () {
    final boolean = ModularTracker.injector.get<bool>();
    expect(boolean, false);
  });

  test('replace binds with interface', () {
    final result = ModularTracker.injector.get<IRepo>();
    expect(result, isA<RepoImpl2>());
    expect(result.name, 'RepoImpl2');
  });
}

class _Bind<T extends Object> extends BindContract<T> {
  _Bind(T Function(Injector i) factoryFunction) : super(factoryFunction);
}
