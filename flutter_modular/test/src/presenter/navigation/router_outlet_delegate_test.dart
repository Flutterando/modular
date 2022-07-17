import 'package:flutter/material.dart';
import 'package:flutter_modular/src/presenter/models/route.dart';
import 'package:flutter_modular/src/presenter/navigation/custom_navigator.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_book.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_router_delegate.dart';
import 'package:flutter_modular/src/presenter/navigation/router_outlet_delegate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../modular_base_test.dart';
import 'modular_page_test.dart';

class ModularRouterDelegateMock extends Mock implements ModularRouterDelegate {}

class NavigatorKeyMock<T extends State> extends Mock implements GlobalKey<T> {}

class NavigatorStateMock extends Mock implements NavigatorState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '';
  }
}

class NavigatorObserverMock extends Mock implements NavigatorObserver {}

void main() {
  late ModularRouterDelegateMock modularRouterDelegateMock;
  late RouterOutletDelegate outlet;
  late NavigatorKeyMock<NavigatorState> key;
  late NavigatorStateMock navigatorState;
  late NavigatorObserverMock navigatorObserver;

  setUp(() {
    modularRouterDelegateMock = ModularRouterDelegateMock();
    key = NavigatorKeyMock<NavigatorState>();
    navigatorState = NavigatorStateMock();
    navigatorObserver = NavigatorObserverMock();
    when(() => key.currentState).thenReturn(navigatorState);
    outlet = RouterOutletDelegate(
        'outlet', modularRouterDelegateMock, key, [navigatorObserver]);
  });

  test('setNewRoutePath...', () {
    expect(() async => await outlet.setNewRoutePath(ParallelRoute.empty()),
        throwsA(isAssertionError));
  });

  test('build', () {
    var widget = outlet.build(BuildContextMock());
    expect(widget, isA<Material>());

    final route1 = ParallelRouteMock();
    final route2 = ParallelRouteMock();
    when(() => route1.uri).thenReturn(Uri.parse('/'));
    when(() => route1.copyWith(schema: '')).thenReturn(route1);
    when(() => route1.schema).thenReturn('');

    when(() => route2.uri).thenReturn(Uri.parse('/pushForce'));
    when(() => route2.copyWith(schema: 'outlet')).thenReturn(route2);
    when(() => route2.schema).thenReturn('outlet');

    when(() => modularRouterDelegateMock.currentConfiguration)
        .thenReturn(ModularBook(routes: [route1, route2]));
    widget = outlet.build(BuildContextMock());
    expect(widget, isA<CustomNavigator>());
  });
}
