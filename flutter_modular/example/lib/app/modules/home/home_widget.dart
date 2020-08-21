import 'package:example/app/modules/home/home_bloc.dart';
import 'package:example/app/modules/home/home_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class HomeWidget extends ModularStatelessWidget<HomeModule> {
  HomeWidget() {
    var c = Modular.get<HomeBloc>();
    c.addListener(() {
      if (c.counter > 10) {
        Modular.to.showDialog(
          child: AlertDialog(
            title: Text('Test'),
            content: Text('Content'),
          ),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HomeModule"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Modular.link.pushNamed('/list/${get<HomeBloc>().counter}');
            },
            child: Text("LIST"),
          )
        ],
      ),
      body: Center(
        child: Consumer<HomeBloc>(builder: (context, value) {
          return Text('Counter ${value.counter}');
        }),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          get<HomeBloc>().increment();
          //Modular.to.pushNamed('/home');
        },
      ),
    );
  }
}
