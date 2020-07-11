import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'home_bloc.dart';

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(Modular.get<HomeBloc>().testingText),
    );
  }
}
