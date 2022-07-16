import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';
import 'package:shelf_modular/src/domain/errors/errors.dart';
import 'package:shelf_modular/src/domain/services/bind_service.dart';
import 'package:shelf_modular/src/infra/services/bind_service_impl.dart';
import 'package:shelf_modular/src/shared/either.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

void main() {
  late Injector injector;
  late BindService service;

  setUpAll(() {
    print('Setup');
    injector = InjectorMock();
    service = BindServiceImpl(injector);
  });

  tearDown(() {
    print('TearDown');
    reset(injector);
  });

  group('getBind', () {
    test('should get bind', () {
      print('1');
      when(() => injector.get<String>()).thenAnswer((_) => 'test');
      expect(service.getBind<String>().getOrElse((left) => ''), 'test');
    });
    test('should throw error not found bind', () {
      print('2');
      when(() => injector.get<String>()).thenThrow(BindNotFound('String'));
      expect(
          service.getBind<String>().fold(id, id), isA<BindNotFoundException>());
    });
  });

  group('dispose', () {
    test('should return true', () {
      print('3');
      when(() => injector.dispose<String>()).thenReturn(true);
      expect(service.disposeBind<String>().getOrElse((left) => false), true);
    });
  });

  group('releaseScopedBinds', () {
    test('should return true', () {
      print('4');
      when(() => injector.removeScopedBinds()).thenReturn(0);
      expect(
          service.releaseScopedBinds().getOrElse((left) => throw left), unit);
    });
  });
}
