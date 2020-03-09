import 'package:example/app/modules/tabs/tabs_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'modules/tab1/tab1_module.dart';

class TabsPage extends StatefulWidget {
  final String title;
  const TabsPage({Key key, this.title = "Tabs"}) : super(key: key);

  @override
  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends ModularState<TabsPage, TabsBloc> {
  //use 'controller' variable to access controller

  int selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: IndexedStack(
        index: selectedPage,
        children: <Widget>[
          RouterOutlet(
            module: Tab1Module(),
          ),
          Container(
            color: Colors.red,
          ),
          Container(
            color: Colors.blue,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedPage,
          onTap: (index) {
            setState(() {
              selectedPage = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.add), title: Text('data')),
            BottomNavigationBarItem(icon: Icon(Icons.add), title: Text('data')),
            BottomNavigationBarItem(icon: Icon(Icons.add), title: Text('data')),
          ]),
    );
  }
}
