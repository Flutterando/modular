import 'package:flutter/material.dart';
import 'package:flutter_modular/src/interfaces/child_module.dart';
import 'package:flutter_modular/src/widgets/router_outlet.dart';

import '../modular_base.dart';

class RouterOutletList extends StatefulWidget {
  final List<ChildModule> modules;
  final ScrollPhysics physics;
  final RouterOutletListController controller;
  const RouterOutletList(
      {Key key,
      @required this.modules,
      this.physics = const NeverScrollableScrollPhysics(),
      @required this.controller})
      : super(key: key);
  @override
  _RouterOutletListState createState() => _RouterOutletListState();
}

class _RouterOutletListState extends State<RouterOutletList> {
  @override
  void initState() {
    widget.controller.init(widget.modules);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller._dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
        physics: widget.physics,
        controller: widget.controller._pageController,
        onPageChanged: widget.controller.changeModule,
        children: widget.modules
            .map((e) => RouterOutlet(
                  module: e,
                ))
            .toList());
  }
}

class RouterOutletListController {
  final _pageController = PageController();
  List<ChildModule> _modules;
  ValueChanged<int> _listen;
  void init(List<ChildModule> modules) {
    _modules = modules;
    Modular.currentNavigatorOutlet = _modules[0].runtimeType.toString();
  }

  void changeModule(int index) {
    Modular.currentNavigatorOutlet = _modules[index].runtimeType.toString();
    _pageController.jumpToPage(index);
    if (_listen != null) {
      _listen(index);
    }
  }

  void listen(ValueChanged<int> current) {
    _listen = current;
  }

  void _dispose() {
    _pageController.dispose();
  }
}
