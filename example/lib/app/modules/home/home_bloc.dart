import 'package:flutter/material.dart';

class HomeBloc extends ChangeNotifier{

  int counter = 0;


  increment(){
    counter++;
    notifyListeners();
  }


}