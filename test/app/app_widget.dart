import 'package:flutter/material.dart';
import 'package:modular/modular.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      onGenerateRoute: Modular.generateRoute,
      onUnknownRoute: (context) {
        return MaterialPageRoute(builder: (context)=> Scaffold(
          appBar: AppBar(title: Text('Página não encontrada'),),
        ));
      },
    );
  }
}