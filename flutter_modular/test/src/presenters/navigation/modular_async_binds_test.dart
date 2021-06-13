import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AsyncBind', () {
    test('by itself', () async {
      final module = AsyncModule();
      final boolVar = module.getBind<bool>(typesInRequest: []);
      expect(boolVar, isTrue);
      await module.isReady();
      final string = module.getBind<String>(typesInRequest: []);
      expect(string, equals('Async Kuringa'));
    });

    test('with Modular', () async {
      Modular.init(AsyncModule());
      final boolVar = Modular.get<bool>();
      expect(boolVar, isTrue);
      await Modular.isModuleReady<AsyncModule>();
      final string = Modular.get<String>();
      expect(string, equals('Async Kuringa'));
    });
  });
}

class AsyncModule extends Module {
  @override
  final List<Bind<Object>> binds = [
    Bind.instance<bool>(true),
    AsyncBind<String>((i) => asyncString()),
  ];
}

Future<String> asyncString() async => 'Async Kuringa';
