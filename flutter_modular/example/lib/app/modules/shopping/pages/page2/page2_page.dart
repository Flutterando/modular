import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'page2_bloc.dart';

class Page2Page extends StatefulWidget {
  final String title;
  const Page2Page({Key key, this.title = "Page2"}) : super(key: key);

  @override
  _Page2PageState createState() => _Page2PageState();
}

class _Page2PageState extends ModularState<Page2Page, Page2Bloc> {
  //use 'controller' variable to access controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[],
      ),
    );
  }
}
