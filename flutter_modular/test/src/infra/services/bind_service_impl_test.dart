import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/domain/errors/errors.dart';
import 'package:flutter_modular/src/domain/services/bind_service.dart';
import 'package:flutter_modular/src/infra/services/bind_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/mocks.dart';

void main() {
  late InjectorMock injector;
  late BindService service;

  setUp(() {
    injector = InjectorMock();
    service = BindServiceImpl(injector);
  });

  tearDown(() => reset(injector));

  group('getBind', () {
    test('should get bind', () {
      when(() => injector.get<String>()).thenReturn('test');
      expect(service.getBind<String>().getOrNull(), 'test');
    });
    test('should throw error not found bind', () {
      when(() => injector.get<String>()).thenThrow(AutoInjectorException('String'));
      expect(service.getBind<String>().exceptionOrNull(), isA<BindNotFoundException>());
    });
  });

  group('dispose', () {
    test('should return true', () {
      when(() => injector.disposeSingleton<String>()).thenReturn('');
      expect(service.disposeBind<String>().getOrNull(), true);
    });
  });

  group('replaceInstance', () {
    test('should replace instance returning unit', () {
      const instance = 'String';
      when(() => injector.isAdded<String>()).thenReturn(true);
      when(() => injector.replaceInstance<String>(instance)).thenReturnVoid();

      final result = service.replaceInstance<String>(instance);

      expect(result.isSuccess(), true);
    });

    test('should return error if instance unregistred', () async {
      const instance = 'String';
      when(() => injector.isAdded<String>()).thenReturn(false);

      final result = service.replaceInstance<String>(instance);

      expect(result.isError(), true);
    });
  });
}
