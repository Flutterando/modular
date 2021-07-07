import 'package:mockito/mockito.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/presenters/modular_impl.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_route_information_parser.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_router_delegate.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  final injectMap = <String, Module>{};

  late final routeInformationParser = ModularRouteInformationParser();
  late final routerDelegate = ModularRouterDelegate(
    parser: routeInformationParser,
    injectMap: injectMap,
  );
  final flags = ModularFlags();

  var modularImpl = ModularImpl(routerDelegate: routerDelegate, injectMap: injectMap, flags: flags);
  modularImpl.init(ModuleMock());
  var navigatorMock = NavigatorMock();

  test('should override the navigator properly', () async {
    var routeName = '/test-navigation';
    modularImpl.navigatorDelegate = navigatorMock;
    when(navigatorMock.pushNamed(routeName)).thenAnswer((_) async => {});
    modularImpl.to.pushNamed(routeName);

    verify(navigatorMock.pushNamed(routeName)).called(1);
  });
}

class ModuleMock extends Module {
  @override
  final List<Bind> binds = [
    Bind.factory((i) => true),
  ];

  @override
  final List<ModularRoute> routes = [];
}

class NavigatorMock extends Mock implements IModularNavigator {
  @override
  Future<T?> pushNamed<T extends Object?>(String? routeName, {Object? arguments, bool? forRoot = false}) =>
      (super.noSuchMethod(Invocation.method(#pushNamed, [routeName], {#arguments: arguments, #forRoot: forRoot}), returnValue: Future.value(null)) as Future<T?>);
}
