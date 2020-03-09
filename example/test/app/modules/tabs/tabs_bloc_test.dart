import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:example/app/app_module.dart';
import 'package:example/app/modules/tabs/tabs_bloc.dart';
import 'package:example/app/modules/tabs/tabs_module.dart';

void main() {
  Modular.init(AppModule());
  Modular.bindModule(TabsModule());
  TabsBloc bloc;

  setUp(() {
    bloc = TabsModule.to.get<TabsBloc>();
  });

  group('TabsBloc Test', () {
    test("First Test", () {
      expect(bloc, isInstanceOf<TabsBloc>());
    });
  });
}
