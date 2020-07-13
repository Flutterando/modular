import 'package:example/app/modules/tabs/tabs_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'modules/tab1/tab1_module.dart';
import 'modules/tab2/tab2_module.dart';

class TabsPage extends StatefulWidget {
  final String title;
  const TabsPage({Key key, this.title = "Tabs"}) : super(key: key);

  @override
  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  var controller = RouterOutletListController();
  var currentIndex = 0;
  @override
  void initState() {
    controller.listen((value) {
      setState(() {
        currentIndex = value;
      });
    });
    super.initState();
  }

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
      body: RouterOutletList(
          modules: [Tab1Module(), Tab2Module()], controller: controller),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: controller.changeModule,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.add), title: Text('data')),
            BottomNavigationBarItem(icon: Icon(Icons.add), title: Text('data')),
            BottomNavigationBarItem(icon: Icon(Icons.add), title: Text('data')),
          ]),
    );
  }
}
