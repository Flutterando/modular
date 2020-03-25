import 'package:example/app/app_module.dart';
import 'package:example/app/modules/tabs/modules/tab1/tab1_module.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() {
  Modular.init(AppModule());
  Modular.bindModule(Tab1Module());
  //Tab1Bloc bloc;

  // setUp(() {
  //     bloc = Tab1Module.to.get<Tab1Bloc>();
  // });

  // group('Tab1Bloc Test', () {
  //   test("First Test", () {
  //     expect(bloc, isInstanceOf<Tab1Bloc>());
  //   });
  // });
}
