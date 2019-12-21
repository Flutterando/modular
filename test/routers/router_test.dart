import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

class TestModule extends ChildModule {
  @override
  List<Bind> get binds => [];

  @override
  List<Router> get routers => [];

}

void main() {
  test('throws assertionError routeName is null', () {
    expect(() => Router(null), throwsAssertionError);
  });

  test('throws ArgumentError if module or child was not provide', () {
    expect(() => Router('/'), throwsArgumentError);
  });

  test('throws ArgumentError if both the module and child was provided', () {
    expect(() {
      Router('/',
        module: TestModule(),
        child: (_, __) => SizedBox.shrink()
      );
    }, throwsArgumentError);
  });

  test('throws ArgumentError if transaction is null', () {
    expect(() {
      Router('/',
          child: (_, __) => SizedBox.shrink(),
          transition: null,
      );
    }, throwsArgumentError);
  });
}
