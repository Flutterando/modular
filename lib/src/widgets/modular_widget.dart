import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ModularWidget<IBind> extends StatefulWidget {


  @override
  _ModularWidgetState<IBind> createState() => _ModularWidgetState<IBind>();
}

class _ModularWidgetState<IBind> extends ModularState<ModularWidget, IBind> {
  //use 'controller' variable to access controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Observer(builder: (_) {
          return Text("${controller.valueModel.value}");
        }),
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: controller.increment),
    );
  }
}
