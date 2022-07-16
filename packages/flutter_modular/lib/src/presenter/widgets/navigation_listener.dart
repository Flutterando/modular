import 'package:flutter/material.dart';
import '../../../flutter_modular.dart';

class NavigationListener extends StatefulWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const NavigationListener({Key? key, required this.builder, this.child})
      : super(key: key);

  @override
  NavigationListenerState createState() => NavigationListenerState();
}

class NavigationListenerState extends State<NavigationListener> {
  void listener() => setState(() {});

  @override
  void initState() {
    super.initState();
    Modular.to.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();
    Modular.to.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.child);
  }
}
