import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/src/presenter/models/modular_navigator.dart';
import 'package:flutter_modular/src/presenter/modular_base.dart';
import 'package:flutter_modular/src/presenter/navigation/custom_navigator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class ModularBaseMock extends Mock implements IModularBase {}

class IModularNavigatorMock extends Mock implements IModularNavigator {}

void main() {
  final base = ModularBaseMock();
  final customNavigator = CustomNavigator(
    modularBase: base,
  );
  final state = customNavigator.createState();
  final navigator = IModularNavigatorMock();

  when(() => base.to).thenReturn(navigator);

  test('pushNamed', () {
    when(() => navigator.pushNamed(any())).thenAnswer((_) => Future.value());
    expect(state.pushNamed('/'), completes);
  });

  test('popAndPushNamed', () {
    when(() => navigator.popAndPushNamed(any()))
        .thenAnswer((_) => Future.value());
    expect(state.popAndPushNamed('/'), completes);
  });

  test('pushNamedAndRemoveUntil', () {
    final predicate = ModalRoute.withName('/');
    when(() => navigator.pushNamedAndRemoveUntil(any(), predicate))
        .thenAnswer((_) => Future.value());
    expect(state.pushNamedAndRemoveUntil('/', predicate), completes);
  });

  test('pushReplacementNamed', () {
    when(() => navigator.pushReplacementNamed(any()))
        .thenAnswer((_) => Future.value());
    expect(state.pushReplacementNamed('/'), completes);
  });
}
