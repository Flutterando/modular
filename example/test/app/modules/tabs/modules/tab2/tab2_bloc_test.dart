import 'package:example/app/app_module.dart';
import 'package:example/app/modules/tabs/modules/tab2/tab2_module.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() {
  Modular.init(AppModule());
  Modular.bindModule(Tab2Module());
//  Tab2Bloc bloc;

  // setUp(() {
  //     bloc = Tab2Module.to.get<Tab2Bloc>();
  // });

  // group('Tab2Bloc Test', () {
  //   test("First Test", () {
  //     expect(bloc, isInstanceOf<Tab2Bloc>());
  //   });
  // });
}
