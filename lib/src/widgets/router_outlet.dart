import 'package:flutter/widgets.dart';
import '../../flutter_modular.dart';
import 'widget_module.dart';

class RouterOutlet extends StatefulWidget {
  final ChildModule module;
  final String initialRoute;
  final Key navigatorKey;
  final bool keepAlive;

  RouterOutlet(
      {Key key,
      @required this.module,
      this.navigatorKey,
      this.initialRoute = Modular.initialRoute,
      this.keepAlive = true})
      : super(key: key) {
    module.paths.add(runtimeType.toString());
  }

  @override
  _RouterOutletState createState() => _RouterOutletState();
}

class _RouterOutletState extends State<RouterOutlet>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ModularProvider(
      module: widget.module,
      child: Navigator(
        key: widget.navigatorKey,
        initialRoute: widget.initialRoute,
        onGenerateRoute: (setting) {
          return Modular.generateRoute(setting, widget.module);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
