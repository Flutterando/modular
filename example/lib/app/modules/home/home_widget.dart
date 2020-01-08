import 'package:example/app/modules/home/home_bloc.dart';
import 'package:example/app/modules/home/home_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class HomeWidget extends ModularStatelessWidget<HomeModule> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("HomeModule"),
      actions: <Widget>[
        FlatButton(onPressed: () {
          Navigator.of(context).pushNamed('/list/1');
        }, child: Text("LIST"),)
      ],
      ),
      body: Center(
        child: consumer<HomeBloc>(
          builder: (context, value) {
            return Text('Counter ${value.counter}');
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          get<HomeBloc>().increment();
        },
      ),
    );
  }
}