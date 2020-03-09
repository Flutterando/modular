import 'package:flutter/material.dart';

class Tab2Page extends StatefulWidget {
  final String title;
  const Tab2Page({Key key, this.title = "Tab2"}) : super(key: key);

  @override
  _Tab2PageState createState() => _Tab2PageState();
}

class _Tab2PageState extends State<Tab2Page> {
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
