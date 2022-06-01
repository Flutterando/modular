import 'package:flutter_modular_test/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_modular/flutter_modular.dart';

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

class MyModule extends Module {
  @override
  final binds = [
    Bind.instance<String>('teste'),
    Bind.instance<bool>(true),
    Bind<IRepo>((i) => RepoImpl1()),
  ];
}

void main() {
  final repo = RepoImpl2();

  initModule(MyModule(),
      replaceBinds: [
        Bind.instance<bool>(false),
        Bind.instance<IRepo>(repo),
      ],
      initialModule: true);

  test('init Module', () {
    final text = Modular.get<String>();
    expect(text, 'teste');
  });

  test('replace binds', () {
    final boolean = Modular.get<bool>();
    expect(boolean, false);
  });

  test('replace binds with interface', () {
    final result = Modular.get<IRepo>();
    expect(result, isA<RepoImpl2>());
    expect(result.name, 'RepoImpl2');
  });
}
