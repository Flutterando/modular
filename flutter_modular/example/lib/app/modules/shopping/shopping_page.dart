import 'package:example/app/modules/shopping/pages/page1/page1_page.dart';
import 'package:example/app/modules/shopping/pages/page2/page2_page.dart';
import 'package:example/app/modules/shopping/pages/page3/page3_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'shopping_bloc.dart';

class ShoppingPage extends StatefulWidget {
  final String title;
  const ShoppingPage({Key key, this.title = "Shopping"}) : super(key: key);

  @override
  _ShoppingPageState createState() => _ShoppingPageState();
}

class _ShoppingPageState extends ModularState<ShoppingPage, ShoppingBloc> {
  //use 'controller' variable to access controller

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            bottom: TabBar(tabs: [
              Tab(
                text: "Page1",
              ),
              Tab(
                text: "Page2",
              ),
              Tab(
                text: "Page3",
              )
            ]),
          ),
          body: TabBarView(children: [Page1Page(), Page2Page(), Page3Page()])),
    );
  }
}
