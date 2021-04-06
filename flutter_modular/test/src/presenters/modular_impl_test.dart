import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/presenters/modular_impl.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_route_information_parser.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_router_delegate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'modular_impl_test.mocks.dart';


@GenerateMocks([IModularNavigator])
main() {
  final injectMap = <String, Module>{};

  late final routeInformationParser = ModularRouteInformationParser();
  late final routerDelegate = ModularRouterDelegate(
    routeInformationParser,
    injectMap,
  );

  var modularImpl = ModularImpl(
      routerDelegate: routerDelegate,
      injectMap: injectMap
  );

  modularImpl.init(ModuleMock());

  var navigatorMock = MockIModularNavigator();

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
  final List<Bind> binds = [];

  @override
  final List<ModularRoute> routes = [];
}
