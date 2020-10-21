import 'package:flutter/material.dart';

import 'modular_route_path.dart';
import 'transitionDelegate.dart';

class ModularRouterDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;

  ModularRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

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
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(BookRoutePath path) async {
    // if (path.isDetailsPage) {
    //   _selectedBook = books[path.id];
    // }
  }

  void _handleBookTapped(dynamic book) {
    // _selectedBook = book;
    // notifyListeners();
  }
}
