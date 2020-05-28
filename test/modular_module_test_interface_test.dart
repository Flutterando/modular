import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'app/app_module.dart';
import 'app/app_module_test_modular.dart';
import 'app/modules/home/home_module.dart';
import 'app/modules/home/home_module_test_modular.dart';
import 'app/modules/home/home_widget.dart';
import 'app/modules/product/product_module.dart';
import 'app/shared/ILocalRepository.dart';
import 'app/shared/app_info.state.dart';
import 'app/shared/local_mock.dart';
import 'app/shared/local_storage_shared.dart';

class CustomModuleTestMock extends Mock implements IModularTest {}

main() {
  group("change bind", () {
    AppModule app = AppModule();
    InitAppModuleHelper().load();

    test('ILocalStorage is a LocalMock', () {
      expect(Modular.get<ILocalStorage>(), isA<LocalMock>());
    });

    setUp(() {
      InitAppModuleHelper().load();
    });

    tearDown(() {
      Modular.removeModule(app);
    });
  });
  group("IModuleTest", () {
    setUp(() {
      InitAppModuleHelper().load();
    });

    ILocalStorage localStorageBeforeReload = Modular.get<ILocalStorage>();

    test('ILocalStorage is not equal when reload by default', () {
      ILocalStorage localStorageAfterReload = Modular.get<ILocalStorage>();
      expect(localStorageBeforeReload.hashCode,
          isNot(equals(localStorageAfterReload.hashCode)));
    });
    test('ILocalStorage is equals when keepModulesOnMemory', () {
      localStorageBeforeReload = Modular.get<ILocalStorage>();
      InitAppModuleHelper(modularTestType: ModularTestType.keepModulesOnMemory)
          .load();
      ILocalStorage localStorageAfterReload = Modular.get<ILocalStorage>();
      expect(localStorageBeforeReload.hashCode,
          equals(localStorageAfterReload.hashCode));
    });
    test('ILocalStorage Change bind on load on runtime', () {
      IModularTest modularTest = InitAppModuleHelper();
      modularTest.load();

      ILocalStorage localStorageBeforeChangeBind = Modular.get<ILocalStorage>();
      expect(localStorageBeforeChangeBind.runtimeType, equals(LocalMock));

      modularTest.load(changeBinds: [
        Bind<ILocalStorage>((i) => LocalStorageSharePreference()),
      ]);
      ILocalStorage localStorageAfterChangeBind = Modular.get<ILocalStorage>();

      expect(localStorageAfterChangeBind.runtimeType,
          equals(LocalStorageSharePreference));
    });
    test('ILocalStorage getNewOrDefaultDendencies', () {
      IModularTest modularTest = InitAppModuleHelper();

      expect(modularTest.getNewOrDefaultDendencies(null, true), isNull);
      expect(
          modularTest.getNewOrDefaultDendencies(InitAppModuleHelper(), true),
          isNotNull);
    });
    test('ILocalStorage getNewOrDefaultBinds', () {
      IModularTest modularTest = InitAppModuleHelper();

      expect(modularTest.getNewOrDefaultBinds([]), isEmpty);
      expect(modularTest.getNewOrDefaultBinds(null), isNotEmpty);
      expect(modularTest.getNewOrDefaultBinds(null).first,
          isInstanceOf<Bind<ILocalStorage>>());
    });
    test('ILocalStorage memoryManage', () {
      IModularTest modularTest = InitAppModuleHelper();

      modularTest.load();
      expect(Modular.get<ILocalStorage>(), isNotNull);

      modularTest.memoryManage(ModularTestType.keepModulesOnMemory);
      expect(Modular.get<ILocalStorage>(), isNotNull);

      modularTest.memoryManage(ModularTestType.resetModule);

      expect(
        () => Modular.get<ILocalStorage>(),
        throwsA(
          isInstanceOf<ModularError>(),
        ),
      );
    });
    test('ILocalStorage loadModularDependencies', () {
      IModularTest modularTest = InitAppModuleHelper();

      final customModule = CustomModuleTestMock();
      when(customModule.load()).thenReturn(() {});

      modularTest.loadModularDependency(true, customModule);
      verify(customModule.load()).called(1);

      modularTest.loadModularDependency(false, customModule);
      verifyNever(customModule.load());
    });
    test('ILocalStorage load HomeModule', () {
      IModularTest homeModuleTest = InitHomeModuleHelper();
      expect(
        () => Modular.get<AppState>(),
        throwsA(
          isInstanceOf<ModularError>(),
        ),
      );

      homeModuleTest.load();
      expect(
        Modular.get<AppState>(),
        isNotNull,
      );
    });

    // tearDown(() {
    //   Modular.removeModule(app);
    // });
  });
  group("navigation test", () {
    AppModule app = AppModule();
    HomeModule home = HomeModule();
    ProductModule product = ProductModule();
    setUp(() {
      initModule(app, initialModule: true);
      initModules([home, product]);
    });
    testWidgets('on pushNamed modify actualRoute ',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(HomeWidget()));
      Modular.to.pushNamed('/prod');
      expect(Modular.link.path, '/prod');
    });
    tearDown(() {
      Modular.removeModule(product);
      Modular.removeModule(home);
      Modular.removeModule(app);
    });
  });
  group("arguments test", () {
    AppModule app = AppModule();
    HomeModule home = HomeModule();
    setUpAll(() {
      initModule(app, initialModule: true);
    });
    testWidgets("Arguments Page id", (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(ArgumentsPage(
        id: 10,
      )));
      final titleFinder = find.text("10");
      expect(titleFinder, findsOneWidget);
    });
    testWidgets("Modular Arguments Page id", (WidgetTester tester) async {
      Modular.arguments(data: 10);
      await tester.pumpWidget(buildTestableWidget(ModularArgumentsPage()));
      final titleFinder = find.text("10");
      expect(titleFinder, findsOneWidget);
    });
    tearDownAll(() {
      Modular.removeModule(home);
      Modular.removeModule(app);
    });
  });
}
