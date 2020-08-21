import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

class TestModule extends ChildModule {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRouter> get routers => [];

}

void main() {
  test('throws assertionError routeName is null', () {
    expect(() => ModularRouter(null), throwsAssertionError);
  });

  test('throws ArgumentError if module or child was not provide', () {
    expect(() => ModularRouter('/'), throwsArgumentError);
  });

  test('throws ArgumentError if both the module and child was provided', () {
    expect(() {
      ModularRouter('/',
        module: TestModule(),
        child: (_, __) => SizedBox.shrink()
      );
    }, throwsArgumentError);
  });

  test('throws ArgumentError if transaction is null', () {
    expect(() {
      ModularRouter('/',
          child: (_, __) => SizedBox.shrink(),
          transition: null,
      );
    }, throwsArgumentError);
  });
}
