import 'package:flutter/widgets.dart';

import 'package:flutter_modular/src/core/models/modular_router.dart';
import 'package:flutter_modular/src/presenters/modular_base.dart';
import 'package:flutter_modular/src/presenters/navigation/modular_router_delegate.dart';

import 'route_outlet_information_parser.dart';
import 'router_outlet_delegate.dart';

// class RouterOutlet extends StatelessWidget {
//   final navigatorKey = GlobalKey<NavigatorState>();
//   final parser = RouterOutletInformationParser();
//   final provider = Providerd();
//   late final delegate = RouterOutletDelegate(navigatorKey, parser, {});

//   @override
//   Widget build(BuildContext context) {

//     return Router(
//       routeInformationProvider: provider,
//       routeInformationParser: parser,
//       routerDelegate: delegate,
//     );
//   }
// }

class Providerd extends RouteInformationProvider {
  final ModularRouterDelegate _delegate;
  Providerd(this._delegate);

  @override
  void addListener(listener) {
    print(listener);
    print(Modular.to.path);
  }

  @override
  void removeListener(listener) {
    print('removeListener');
  }

  @override
  RouteInformation? get value => RouteInformation(location: '/other');
}

// class RouterOutlet extends StatefulWidget {
//   final ChildModule module;
//   final String initialRoute;
//   final Key navigatorKey;
//   final bool keepAlive;
//   final void Function(String route) onChangeRoute;

//   RouterOutlet({
//     Key key,
//     @required this.module,
//     this.navigatorKey,
//     this.initialRoute = '/',
//     this.keepAlive = true,
//     this.onChangeRoute,
//   }) : super(key: key) {
//     module.paths.add(runtimeType.toString());
//   }

//   @override
//   _RouterOutletState createState() => _RouterOutletState();
// }

// class _RouterOutletState extends State<RouterOutlet>
//     with AutomaticKeepAliveClientMixin {
//   GlobalKey<NavigatorState> _key;
//   @override
//   void initState() {
//     super.initState();
//     //  _key = widget.navigatorKey ??
//     //    Modular.outletNavigatorKey(widget.module.runtimeType.toString());
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return WillPopScope(
//       onWillPop: () async {
//         return !await _key.currentState.maybePop();
//       },
//       child: ModularProvider(
//         module: widget.module,
//         child: Navigator(
//           key: _key,
//           initialRoute: widget.initialRoute,
//           // onGenerateRoute: (setting) {
//           //   return Modular.generateRoute(
//           //       setting, widget.module, widget.onChangeRoute);
//           // },
//         ),
//       ),
//     );
//   }

//   @override
//   bool get wantKeepAlive => widget.keepAlive;
// }
