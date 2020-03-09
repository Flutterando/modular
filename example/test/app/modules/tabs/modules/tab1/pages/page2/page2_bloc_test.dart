import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:example/app/app_module.dart';
import 'package:example/app/modules/tabs/modules/tab1/pages/page2/page2_bloc.dart';
import 'package:example/app/modules/tabs/modules/tab1/tab1_module.dart';

void main() {
  Modular.init(AppModule());
  Modular.bindModule(Tab1Module());
  Page2Bloc bloc;

  // setUp(() {
  //     bloc = Tab1Module.to.get<Page2Bloc>();
  // });

  // group('Page2Bloc Test', () {
  //   test("First Test", () {
  //     expect(bloc, isInstanceOf<Page2Bloc>());
  //   });
  // });
}
