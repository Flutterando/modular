import 'package:flutter/material.dart';

class Page3Page extends StatefulWidget {
  final String title;
  const Page3Page({Key key, this.title = "Page3"}) : super(key: key);

  @override
  _Page3PageState createState() => _Page3PageState();
}

class _Page3PageState extends State<Page3Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: RaisedButton(
            child: Text('Go to Page 4'),
            onPressed: () {
              Navigator.of(context).pushNamed('/page4');
            }),
      ),
    );
  }
}
