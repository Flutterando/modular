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

class CustomLocalStorage extends Mock implements ILocalStorage {}

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
    test('ILocalStorage getDendencies', () {
      IModularTest modularTest = InitAppModuleHelper();

      expect(modularTest.getDendencies(null, true), isNull);
      expect(modularTest.getDendencies(InitAppModuleHelper(), true), isNotNull);
    });
    test('ILocalStorage getBinds', () {
      IModularTest modularTest = InitAppModuleHelper();

      expect(modularTest.getBinds([]).length, modularTest.binds().length);
      expect(modularTest.getBinds(null), isNotEmpty);
      expect(modularTest.getBinds(null).first,
          isInstanceOf<Bind<ILocalStorage>>());

      Bind<String> stringBind = Bind<String>((i) => "teste");
      List<Bind> changeBinds = [
        Bind<ILocalStorage>((i) => LocalStorageSharePreference()),
        stringBind,
      ];

      expect(modularTest.getBinds(changeBinds), containsAll(changeBinds));
    });
    test('ILocalStorage mergeBinds', () {
      IModularTest modularTest = InitAppModuleHelper();
      Bind<String> stringBind = Bind<String>((i) => "teste");
      List<Bind> changeBinds = [
        Bind<ILocalStorage>((i) => LocalMock()),
      ];
      List<Bind> defaultBinds = [
        Bind<ILocalStorage>((i) => LocalStorageSharePreference()),
        stringBind,
      ];

      expect(modularTest.mergeBinds(changeBinds, defaultBinds),
          containsAll([changeBinds.first, stringBind]));
      expect(modularTest.mergeBinds(changeBinds, null), equals(changeBinds));
      expect(modularTest.mergeBinds(null, defaultBinds), equals(defaultBinds));
      expect(modularTest.mergeBinds(null, null), equals([]));
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
    test('ILocalStorage loadModularDependency', () {
      IModularTest modularTest = InitAppModuleHelper();

      final customModule = CustomModuleTestMock();
      when(customModule.load(changeBinds: anyNamed("changeBinds")))
          .thenReturn(() {});

      modularTest.loadModularDependency(true, [], customModule);
      verify(customModule.load(changeBinds: anyNamed("changeBinds"))).called(1);

      modularTest.loadModularDependency(false, [], customModule);
      verifyNever(customModule.load(changeBinds: anyNamed("changeBinds")));
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

    test('Changing binds of parent modules', () {
      IModularTest homeModuleTest = InitHomeModuleHelper();

      homeModuleTest.load();
      ILocalStorage instance = Modular.get();

      expect(
        instance,
        isInstanceOf<LocalMock>(),
      );

      homeModuleTest.load(changeBinds: [
        Bind<ILocalStorage>(
          (i) => CustomLocalStorage(),
        )
      ]);

      expect(
        Modular.get<ILocalStorage>(),
        isInstanceOf<CustomLocalStorage>(),
      );

      homeModuleTest.load(changeBinds: [
        Bind<String>(
          (i) => "test",
        )
      ]);

      expect(
        Modular.get<ILocalStorage>(),
        isInstanceOf<LocalMock>(),
      );
      
      expect(
        ()=>Modular.get<String>(),
        throwsA(isInstanceOf<ModularError>()),
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
