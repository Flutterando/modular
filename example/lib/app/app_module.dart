import 'package:flutter/material.dart';
import 'package:modular/modular.dart';

import 'app_bloc.dart';
import 'app_widget.dart';
import 'modules/home/home_module.dart';

class AppModule extends BrowserModule {
  @override
  List<Bind> get binds => [
        Bind((i) => AppBloc()),
      ];

  @override
  List<Router> get routers => [
        Router("/", module: HomeModule()),
        Router("/home", module: HomeModule()),
      ];

  @override
  Widget get bootstrap => AppWidget();
}
