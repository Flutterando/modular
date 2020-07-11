import 'package:flutter/foundation.dart';

class HomeBloc extends ChangeNotifier {
  int counter = 0;

  increment() {
    counter++;
    notifyListeners();
  }
}
