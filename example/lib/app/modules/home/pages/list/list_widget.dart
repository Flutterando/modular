import 'package:example/app/modules/home/home_bloc.dart';
import 'package:example/app/modules/home/home_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ListWidget extends ModularStatelessWidget<HomeModule> {
  final int param;

  ListWidget({Key key, this.param = 1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PARAM id = $param"),
      ),
      body: Center(
        child: Text("${Modular.get<HomeBloc>().counter}"),
      ),
    );
  }
}
