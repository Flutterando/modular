import 'package:flutter/material.dart';

import 'package:flutter_modular/flutter_modular.dart';

import 'modules/tab1/tab1_module.dart';
import 'modules/tab2/tab2_module.dart';

import 'tabs_bloc.dart';

class TabsPage extends StatefulWidget {
  final String title;
  const TabsPage({Key key, this.title = "Tabs"}) : super(key: key);

  @override
  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends ModularState<TabsPage, TabsBloc> {
  //use 'controller' variable to access controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          RaisedButton(
            onPressed: () {
              Modular.to.pushNamed('/home');
            },
            child: Text('HOME'),
          )
        ],
      ),
      body: StreamBuilder<int>(
          stream: controller.selectedPage,
          initialData: 0,
          builder: (context, snapshot) {
            int selectedPage = snapshot.data;
            return IndexedStack(
              index: selectedPage,
              children: <Widget>[
                RouterOutlet(
                  module: Tab1Module(),
                ),
                RouterOutlet(
                  module: Tab2Module(),
                ),
                Container(
                  color: Colors.blue,
                ),
              ],
            );
          }),
      bottomNavigationBar: StreamBuilder<int>(
          stream: controller.selectedPage,
          initialData: 0,
          builder: (context, snapshot) {
            int selectedPage = snapshot.data;

            return BottomNavigationBar(
                currentIndex: selectedPage,
                onTap: (index) {
                  controller.selectedPage.add(index);
                },
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.add), title: Text('data')),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.add), title: Text('data')),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.add), title: Text('data')),
                ]);
          }),
    );
  }
}
