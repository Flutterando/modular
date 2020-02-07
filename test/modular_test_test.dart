import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/flutter_modular_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app/app_module.dart';
import 'app/shared/ILocalRepository.dart';
import 'app/shared/local_mock.dart';

main() {
  test('change bind', () {
    initModule(AppModule(), changeBinds: [
      Bind<ILocalStorage>((i) => LocalMock()),
    ]);
    expect(Modular.get<ILocalStorage>(), isA<LocalMock>());
  });
}
