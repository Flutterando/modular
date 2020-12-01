import 'package:flutter/widgets.dart';

import 'widget_module.dart';

class RouterOutlet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
    // return Router(
    //   routerDelegate: null,
    // );
  }
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
