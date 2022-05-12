import 'package:flutter/material.dart';
import 'package:flutter_modular/src/domain/usecases/report_pop.dart';
import 'package:flutter_modular/src/presenter/models/modular_args.dart';
import 'package:flutter_modular/src/presenter/navigation/custom_navigator.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_book.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_page.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_route_information_parser.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_router_delegate.dart';
import 'package:flutter_modular/src/shared/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';

import '../../mocks/mocks.dart';
import '../modular_base_test.dart' hide GetArgumentsMock, SetArgumentsMock;
import 'modular_page_test.dart';
import 'modular_route_information_parser_test.dart';

class ModularRouteInformationParserMock extends Mock
    implements ModularRouteInformationParser {}

class BuildContextMock extends Mock implements BuildContext {}

class RouteMock extends Mock implements Route {}

class ReportPopMock extends Mock implements ReportPop {}

class NavigatorKeyMock<T extends State> extends Mock implements GlobalKey<T> {}

class NavigatorStateMock extends Mock implements NavigatorState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '';
  }
}

void main() {
  late ModularRouterDelegate delegate;
  late ModularRouteInformationParserMock parser;
  late NavigatorKeyMock<NavigatorState> key;
  late NavigatorStateMock navigatorState;
  late ReportPopMock reportPopMock;

  setUpAll(() {
    registerFallbackValue<ModularArguments>(ModularArguments.empty());
    registerFallbackValue<ModularRoute>(ModularRouteMock());
  });

  setUp(() {
    key = NavigatorKeyMock<NavigatorState>();
    navigatorState = NavigatorStateMock();
    reportPopMock = ReportPopMock();
    when(() => key.currentState).thenReturn(navigatorState);
    parser = ModularRouteInformationParserMock();
    delegate = ModularRouterDelegate(
      parser: parser,
      navigatorKey: key,
      reportPop: reportPopMock,
    );
  });

  test('setObserver', () {
    delegate.setObservers([NavigatorObserver()]);
    expect(delegate.observers.length, 1);
  });

  test('setNavigatorKey', () {
    final key = GlobalKey<NavigatorState>();
    delegate.setNavigatorKey(key);
    expect(delegate.navigatorKey, key);
  });

  test('build', () {
    final context = BuildContextMock();
    var widget = delegate.build(context);
    expect(widget, isA<Material>());

    final route = ParallelRouteMock();
    when(() => route.schema).thenReturn('');
    when(() => route.uri).thenReturn(Uri.parse('/'));

    delegate.currentConfiguration = ModularBook(routes: [route]);
    widget = delegate.build(context);
    expect(widget, isA<CustomNavigator>());
    expect(delegate.navigateHistory, delegate.currentConfiguration?.routes);
  });

  test('Book copywith', () {
    expect(const ModularBook(routes: []).copyWith(), isA<ModularBook>());
  });

  test('navigate blink', () async {
    final route1 = ParallelRouteMock();
    when(() => route1.uri).thenReturn(Uri.parse('/test2'));
    when(() => parser.selectBook('/test2'))
        .thenAnswer((_) async => ModularBook(routes: [route1]));

    delegate.navigate('/test');
    delegate.navigate('/test2');
    delegate.navigate('/test');
    delegate.navigate('/test2');

    await Future.delayed(const Duration(seconds: 1));
    expect(delegate.currentConfiguration?.uri.toString(), '/test2');
    expect(delegate.navigateHistory, delegate.currentConfiguration?.routes);
  });

  test('navigate', () async {
    final route1 = ParallelRouteMock();
    when(() => route1.uri).thenReturn(Uri.parse('/test'));
    when(() => parser.selectBook('/test'))
        .thenAnswer((_) async => ModularBook(routes: [route1]));

    final getArgsMock = GetArgumentsMock();
    final setArgsMock = SetArgumentsMock();

    when(() => parser.getArguments).thenReturn(getArgsMock);
    when(() => parser.setArguments).thenReturn(setArgsMock);

    final arguments = ModularArguments.empty();

    when(() => getArgsMock.call()).thenReturn(right(arguments));
    when(() => setArgsMock.call(any())).thenReturn(right(unit));

    await delegate.navigate('/');
    await delegate.navigate('/test');
    await Future.delayed(const Duration(milliseconds: 600));
    await delegate.navigate('/test');
    expect(delegate.currentConfiguration?.uri.toString(), '/test');
    expect(delegate.path, '/test');
    expect(delegate.navigateHistory, delegate.currentConfiguration!.routes);
  });
  test('onPopPage', () {
    final route = RouteMock();
    final parallel = ParallelRouteMock();
    when(() => parallel.uri).thenReturn(Uri.parse('/'));
    final page = ModularPage(
        route: parallel, args: ModularArguments.empty(), flags: ModularFlags());
    when(() => route.didPop(null)).thenReturn(true);
    when(() => route.settings).thenReturn(page);
    when(() => route.isFirst).thenReturn(false);

    when(() => reportPopMock.call(parallel)).thenReturn(right(unit));

    final arguments = ModularArguments.empty();
    final getArgsMock = GetArgumentsMock();
    final setArgsMock = SetArgumentsMock();
    when(() => parser.getArguments).thenReturn(getArgsMock);
    when(() => parser.setArguments).thenReturn(setArgsMock);

    when(() => getArgsMock.call()).thenReturn(right(arguments));
    when(() => setArgsMock.call(any())).thenReturn(right(unit));

    delegate.currentConfiguration = ModularBook(routes: [parallel]);
    expect(delegate.currentConfiguration?.routes.length, 1);
    delegate.onPopPage(route, null);
    expect(delegate.currentConfiguration?.routes.length, 0);
    expect(delegate.navigateHistory, delegate.currentConfiguration?.routes);
  });

  test('pushNamed with forRoot', () async {
    final route1 = ParallelRouteMock();
    final route2 = ParallelRouteMock();
    when(() => route1.uri).thenReturn(Uri.parse('/'));
    when(() => route1.copyWith(schema: '')).thenReturn(route1);
    when(() => route1.schema).thenReturn('');

    when(() => route2.uri).thenReturn(Uri.parse('/pushForce'));
    when(() => route2.copyWith(schema: '')).thenReturn(route2);
    when(() => route2.schema).thenReturn('');

    final getArgsMock = GetArgumentsMock();
    final setArgsMock = SetArgumentsMock();

    when(() => parser.getArguments).thenReturn(getArgsMock);
    when(() => parser.setArguments).thenReturn(setArgsMock);

    final arguments = ModularArguments.empty();

    when(() => getArgsMock.call()).thenReturn(right(arguments));
    when(() => setArgsMock.call(any())).thenReturn(right(unit));

    delegate.currentConfiguration = ModularBook(routes: [route1]);

    when(() => parser.selectBook('/pushForce',
            popCallback: any(named: 'popCallback')))
        .thenAnswer((_) async => ModularBook(routes: [route2]));
    // ignore: unawaited_futures
    delegate.pushNamed('/pushForce', forRoot: true);
    await Future.delayed(const Duration(milliseconds: 400));

    expect(delegate.currentConfiguration?.uri.toString(), '/pushForce');
    expect(delegate.currentConfiguration?.routes.length, 2);
    expect(delegate.navigateHistory, delegate.currentConfiguration?.routes);
  });

  test('pushNamed common', () async {
    final route1 = ParallelRouteMock();
    final route2 = ParallelRouteMock();
    when(() => route1.uri).thenReturn(Uri.parse('/'));
    when(() => route1.copyWith(schema: '')).thenReturn(route1);
    when(() => route1.schema).thenReturn('');

    when(() => route2.uri).thenReturn(Uri.parse('/pushForce'));
    when(() => route2.copyWith(schema: '')).thenReturn(route2);
    when(() => route2.schema).thenReturn('');
    when(() => route2.name).thenReturn('/pushForce');

    final getArgsMock = GetArgumentsMock();
    final setArgsMock = SetArgumentsMock();

    when(() => parser.getArguments).thenReturn(getArgsMock);
    when(() => parser.setArguments).thenReturn(setArgsMock);

    final arguments = ModularArguments.empty();

    when(() => getArgsMock.call()).thenReturn(right(arguments));
    when(() => setArgsMock.call(any())).thenReturn(right(unit));

    delegate.currentConfiguration = ModularBook(routes: [route1]);

    when(() => parser.selectBook('/pushForce',
            popCallback: any(named: 'popCallback')))
        .thenAnswer((_) async => ModularBook(routes: [route2]));
    // ignore: unawaited_futures
    delegate.pushNamed('/pushForce');
    await Future.delayed(const Duration(milliseconds: 400));
    // ignore: unawaited_futures
    delegate.pushNamed('/pushForce');
    await Future.delayed(const Duration(milliseconds: 400));

    expect(delegate.currentConfiguration?.uri.toString(), '/pushForce');
    expect(delegate.currentConfiguration?.routes.length, 3);
    expect(delegate.navigateHistory, delegate.currentConfiguration?.routes);
  });

  test('pushReplacementNamed with forRoot', () async {
    final route1 = ParallelRouteMock();
    final route2 = ParallelRouteMock();
    when(() => route1.uri).thenReturn(Uri.parse('/'));
    when(() => route1.copyWith(schema: '')).thenReturn(route1);
    when(() => route1.schema).thenReturn('');

    when(() => route2.uri).thenReturn(Uri.parse('/pushForce'));
    when(() => route2.copyWith(schema: '')).thenReturn(route2);
    when(() => route2.schema).thenReturn('');
    final getArgsMock = GetArgumentsMock();
    final setArgsMock = SetArgumentsMock();

    when(() => parser.getArguments).thenReturn(getArgsMock);
    when(() => parser.setArguments).thenReturn(setArgsMock);

    final arguments = ModularArguments.empty();

    when(() => getArgsMock.call()).thenReturn(right(arguments));
    when(() => setArgsMock.call(any())).thenReturn(right(unit));

    when(() => reportPopMock.call(route1)).thenReturn(right(unit));

    delegate.currentConfiguration = ModularBook(routes: [route1]);

    when(() => parser.selectBook('/pushForce',
            popCallback: any(named: 'popCallback')))
        .thenAnswer((_) async => ModularBook(routes: [route2]));
    // ignore: unawaited_futures
    delegate.pushReplacementNamed('/pushForce', forRoot: true);
    await Future.delayed(const Duration(milliseconds: 400));

    expect(delegate.currentConfiguration?.uri.toString(), '/pushForce');
    expect(delegate.currentConfiguration?.routes.length, 1);
    expect(delegate.navigateHistory, delegate.currentConfiguration?.routes);
  });

  test('pushReplacementNamed common', () async {
    final route1 = ParallelRouteMock();
    final route2 = ParallelRouteMock();
    final route3 = ParallelRouteMock();

    when(() => route1.uri).thenReturn(Uri.parse('/'));
    when(() => route1.copyWith(schema: '')).thenReturn(route1);
    when(() => route1.schema).thenReturn('');

    when(() => route2.uri).thenReturn(Uri.parse('/2'));
    when(() => route2.copyWith(schema: '')).thenReturn(route2);
    when(() => route2.schema).thenReturn('');

    when(() => route3.uri).thenReturn(Uri.parse('/pushForce'));
    when(() => route3.copyWith(schema: '')).thenReturn(route3);
    when(() => route3.schema).thenReturn('');

    when(() => reportPopMock.call(route1)).thenReturn(right(unit));
    when(() => reportPopMock.call(route2)).thenReturn(right(unit));

    final getArgsMock = GetArgumentsMock();
    final setArgsMock = SetArgumentsMock();

    when(() => parser.getArguments).thenReturn(getArgsMock);
    when(() => parser.setArguments).thenReturn(setArgsMock);

    final arguments = ModularArguments.empty();

    when(() => getArgsMock.call()).thenReturn(right(arguments));
    when(() => setArgsMock.call(any())).thenReturn(right(unit));

    delegate.currentConfiguration = ModularBook(routes: [route1, route2]);

    when(() => parser.selectBook('/pushForce',
            popCallback: any(named: 'popCallback')))
        .thenAnswer((_) async => ModularBook(routes: [route3]));
    // ignore: unawaited_futures
    delegate.pushReplacementNamed('/pushForce');
    await Future.delayed(const Duration(milliseconds: 400));

    expect(delegate.currentConfiguration?.uri.toString(), '/pushForce');
    expect(delegate.currentConfiguration?.routes.length, 2);
    expect(delegate.navigateHistory, delegate.currentConfiguration?.routes);
  });

  test('popAndPushNamed ', () async {
    final route1 = ParallelRouteMock();
    final route2 = ParallelRouteMock();
    when(() => route1.uri).thenReturn(Uri.parse('/'));
    when(() => route1.copyWith(schema: '')).thenReturn(route1);
    when(() => route1.schema).thenReturn('');

    when(() => route2.uri).thenReturn(Uri.parse('/pushForce'));
    when(() => route2.copyWith(schema: '')).thenReturn(route2);
    when(() => route2.schema).thenReturn('');

    final getArgsMock = GetArgumentsMock();
    final setArgsMock = SetArgumentsMock();

    when(() => parser.getArguments).thenReturn(getArgsMock);
    when(() => parser.setArguments).thenReturn(setArgsMock);

    final arguments = ModularArguments.empty();

    when(() => getArgsMock.call()).thenReturn(right(arguments));
    when(() => setArgsMock.call(any())).thenReturn(right(unit));

    delegate.currentConfiguration = ModularBook(routes: [route1]);

    when(() => parser.selectBook('/pushForce',
            popCallback: any(named: 'popCallback')))
        .thenAnswer((_) async => ModularBook(routes: [route2]));
    // ignore: unawaited_futures
    delegate.popAndPushNamed('/pushForce');
    await Future.delayed(const Duration(milliseconds: 400));

    expect(delegate.currentConfiguration?.uri.toString(), '/pushForce');
    expect(delegate.navigateHistory, delegate.currentConfiguration?.routes);
  });

  test('pop ', () async {
    when(() => navigatorState.pop()).thenReturn(null);
    delegate.pop();
    verify(() => navigatorState.pop());
  });
  test('push ', () async {
    final route = MaterialPageRoute(builder: (_) => Container());
    when(() => navigatorState.push(route))
        .thenAnswer((_) => Future.value(true));
    await delegate.push(route);
    verify(() => navigatorState.push(route));
  });

  test('canPop ', () async {
    when(() => navigatorState.canPop()).thenReturn(true);
    expect(delegate.canPop(), true);
  });

  test('maybePop ', () async {
    when(() => navigatorState.maybePop()).thenAnswer((_) => Future.value(true));
    expect(await delegate.maybePop(), true);
  });

  test('popUntil ', () async {
    final route1 = ParallelRouteMock();
    final route2 = ParallelRouteMock();
    when(() => route1.uri).thenReturn(Uri.parse('/'));
    when(() => route1.copyWith(schema: '')).thenReturn(route1);
    when(() => route1.schema).thenReturn('');

    when(() => route2.uri).thenReturn(Uri.parse('/pushForce'));
    when(() => route2.copyWith(schema: '')).thenReturn(route2);
    when(() => route2.schema).thenReturn('');

    when(() => navigatorState.popUntil(any())).thenReturn(null);
    delegate.popUntil((_) => false);
    delegate.currentConfiguration = ModularBook(routes: [route1, route2]);
    delegate.popUntil((_) => true);
    verify(() => navigatorState.popUntil(any()));
  });

  test('pushNamedAndRemoveUntil ', () async {
    final route1 = ParallelRouteMock();
    final route2 = ParallelRouteMock();
    final route3 = ParallelRouteMock();

    final arguments = ModularArguments.empty();

    final getArgsMock = GetArgumentsMock();
    final setArgsMock = SetArgumentsMock();

    when(() => getArgsMock.call()).thenReturn(right(arguments));
    when(() => setArgsMock.call(any())).thenReturn(right(unit));

    when(() => parser.getArguments).thenReturn(getArgsMock);
    when(() => parser.setArguments).thenReturn(setArgsMock);

    when(() => reportPopMock.call(any())).thenReturn(right(unit));

    when(() => route1.uri).thenReturn(Uri.parse('/'));
    when(() => route1.copyWith(schema: '')).thenReturn(route1);
    when(() => route1.schema).thenReturn('');

    when(() => route2.uri).thenReturn(Uri.parse('/pushForce'));
    when(() => route2.copyWith(schema: '')).thenReturn(route2);
    when(() => route2.schema).thenReturn('');

    when(() => route3.uri).thenReturn(Uri.parse('/pushForce2'));
    when(() => route3.copyWith(schema: '')).thenReturn(route3);
    when(() => route3.schema).thenReturn('');

    when(() => navigatorState.popUntil(any())).thenReturn(null);

    delegate.currentConfiguration =
        ModularBook(routes: [route1, route2, route3]);

    when(() => parser.selectBook('/pushForce2',
            popCallback: any(named: 'popCallback')))
        .thenAnswer((_) async => ModularBook(routes: [route3]));
    // ignore: unawaited_futures
    delegate.pushNamedAndRemoveUntil('/pushForce2', ModalRoute.withName('/'));
    await Future.delayed(const Duration(milliseconds: 400));

    expect(delegate.currentConfiguration?.uri.toString(), '/pushForce2');
    expect(delegate.currentConfiguration?.routes.length, 2);
  });

  test('pushNamedAndRemoveUntil forRoot', () async {
    final route1 = ParallelRouteMock();
    final route2 = ParallelRouteMock();

    when(() => reportPopMock.call(any())).thenReturn(right(unit));

    when(() => route1.uri).thenReturn(Uri.parse('/'));
    when(() => route1.copyWith(schema: '')).thenReturn(route1);
    when(() => route1.schema).thenReturn('');

    when(() => route2.uri).thenReturn(Uri.parse('/pushForce'));
    when(() => route2.copyWith(schema: '')).thenReturn(route2);
    when(() => route2.schema).thenReturn('');

    when(() => navigatorState.popUntil(any())).thenReturn(null);

    final getArgsMock = GetArgumentsMock();
    final setArgsMock = SetArgumentsMock();
    when(() => parser.getArguments).thenReturn(getArgsMock);
    when(() => parser.setArguments).thenReturn(setArgsMock);

    final arguments = ModularArguments.empty();

    when(() => getArgsMock.call()).thenReturn(right(arguments));
    when(() => setArgsMock.call(any())).thenReturn(right(unit));

    delegate.currentConfiguration = ModularBook(routes: [route1]);

    when(() => parser.selectBook('/pushForce',
            popCallback: any(named: 'popCallback')))
        .thenAnswer((_) async => ModularBook(routes: [route2]));
    // ignore: unawaited_futures
    delegate.pushNamedAndRemoveUntil('/pushForce', (_) => false, forRoot: true);
    await Future.delayed(const Duration(milliseconds: 400));

    expect(delegate.currentConfiguration?.uri.toString(), '/pushForce');
    expect(delegate.currentConfiguration?.routes.length, 1);
  });

  test('CustomModalRoute ', () async {
    final route = CustomModalRoute(ModularPage.empty());
    expect(() => route.barrierColor, throwsA(isA<UnimplementedError>()));
    expect(() => route.barrierDismissible, throwsA(isA<UnimplementedError>()));
    expect(() => route.maintainState, throwsA(isA<UnimplementedError>()));
    expect(() => route.opaque, throwsA(isA<UnimplementedError>()));
    expect(() => route.transitionDuration, throwsA(isA<UnimplementedError>()));
    expect(() => route.barrierLabel, throwsA(isA<UnimplementedError>()));
    expect(
        () => route.buildPage(
            BuildContextMock(), AnimationMock(), AnimationMock()),
        throwsA(isA<UnimplementedError>()));
  });
}
