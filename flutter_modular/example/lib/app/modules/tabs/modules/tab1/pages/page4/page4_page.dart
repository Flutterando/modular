import 'package:flutter/material.dart';

class Page4Page extends StatefulWidget {
  final String title;
  const Page4Page({Key key, this.title = "Page4"}) : super(key: key);

  @override
  _Page4PageState createState() => _Page4PageState();
}

class _Page4PageState extends State<Page4Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: RaisedButton(
            child: Text('Go to Page 3'),
            onPressed: () {
              Navigator.of(context).pushNamed('/page3');
            }),
      ),
    );
  }
}
