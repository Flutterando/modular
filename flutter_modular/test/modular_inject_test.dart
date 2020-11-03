import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/flutter_modular_test.dart';

import 'app/app_bloc.dart';
import 'app/app_module.dart';
import 'app/modules/home/home_bloc.dart';
import 'app/modules/home/home_module.dart';
import 'app/shared/app_info.state.dart';
import 'app/shared/ilocal_repository.dart';
import 'app/shared/local_storage_shared.dart';
import 'app/shared/local_storage_shared_alias.dart';

void main() {
  setUpAll(() {
    initModules([
      AppModule(),
      HomeModule(),
    ]);
  });

  group("Inject", () {
    test('Get withless module', () {
      expect(Modular.get<AppBloc>(), isA<AppBloc>());
      expect(Modular.get<HomeBloc>(), isA<HomeBloc>());
      expect(Modular.get(alias: 'test'), isA<LocalStorageSharePreferenceAlias>());

    });

    test('Get with module', () {
      expect(Modular.get<AppBloc>(module: 'AppModule'), isA<AppBloc>());
      expect(Modular.get<HomeBloc>(module: 'HomeModule'), isA<HomeBloc>());
      expect(Modular.get(module: 'AppModule', alias: 'test'), isA<LocalStorageSharePreferenceAlias>());

    });

    test('Inject not found with module', () {
      expect(() {
        Modular.get<HomeBloc>(module: 'AppModule');
      }, throwsA(isA<ModularError>()));
      expect(() {
        Modular.get<AppBloc>(module: 'HomeModule');
      }, throwsA(isA<ModularError>()));
    });

    test('Inject not found withless module', () {
      expect(Modular.get, throwsA(isA<ModularError>()));
    });

    test('Inject singleton does not create duplicated instances', () {
      var firstState = Modular.get<AppState>().stateId;
      var secondState = Modular.get<AppState>().stateId;
      expect(firstState, secondState);
    });

    test('Get Interface', () {
      expect(Modular.get<LocalStorageSharePreference>(),
          isA<LocalStorageSharePreference>());
      expect(Modular.get<ILocalStorage>(), isA<LocalStorageSharePreference>());
    });
  });
}
