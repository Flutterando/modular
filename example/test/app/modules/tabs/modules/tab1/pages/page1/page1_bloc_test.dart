import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:example/app/app_module.dart';
import 'package:example/app/modules/tabs/modules/tab1/pages/page1/page1_bloc.dart';
import 'package:example/app/modules/tabs/modules/tab1/tab1_module.dart';

void main() {
  Modular.init(AppModule());
  Modular.bindModule(Tab1Module());
  Page1Bloc bloc;

  // setUp(() {
  //     bloc = Tab1Module.to.get<Page1Bloc>();
  // });

  // group('Page1Bloc Test', () {
  //   test("First Test", () {
  //     expect(bloc, isInstanceOf<Page1Bloc>());
  //   });
  // });
}
