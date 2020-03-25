import 'package:example/app/app_module.dart';
import 'package:example/app/modules/tabs/modules/tab1/tab1_module.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() {
  Modular.init(AppModule());
  Modular.bindModule(Tab1Module());
  //Page1Bloc bloc;

  // setUp(() {
  //     bloc = Tab1Module.to.get<Page1Bloc>();
  // });

  // group('Page1Bloc Test', () {
  //   test("First Test", () {
  //     expect(bloc, isInstanceOf<Page1Bloc>());
  //   });
  // });
}
