import 'package:flutter/material.dart';

import 'modular_route_path.dart';
import 'transitionDelegate.dart';

class ModularRouterDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;

  ModularRouterDelegate(this.navigatorKey);

  int counter = 0;

  @override
  BookRoutePath get currentConfiguration =>
      counter == 0 ? BookRoutePath.home() : BookRoutePath.home();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      transitionDelegate: NoAnimationTransitionDelegate(),
      pages: [
        MaterialPage(
          key: ValueKey('BooksListPage'),
          child: Scaffold(),
        ),
        if (counter > 0)
          MaterialPage(
            key: ValueKey('BooksListPage2'),
            child: Scaffold(),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(BookRoutePath path) async {
    if (path?.isDetailsPage == true) {
      counter = 2;
      print(path?.id);
    }
  }

  void handleBookTapped() {
    // _selectedBook = book;
    counter = 2;
    notifyListeners();
  }
}
