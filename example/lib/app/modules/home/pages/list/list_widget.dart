import 'package:example/app/modules/home/home_bloc.dart';
import 'package:example/app/modules/home/home_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../app_bloc.dart';

class ListWidget extends StatelessWidget with InjectMixin<HomeModule> {
  final String param;

  ListWidget({Key key, this.param = "0"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PARAM id = $param"),
      ),
      body: Center(
        child: Text("${get<AppBloc>()}"),
      ),
    );
  }
}
