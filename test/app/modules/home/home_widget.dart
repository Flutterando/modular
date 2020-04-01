import 'package:flutter/material.dart';

import 'home_bloc.dart';
import 'home_module.dart';

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(HomeModule.to.get<HomeBloc>().testingText),
    );
  }
}
