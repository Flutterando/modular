import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'app_widget.dart';

import 'modules/home/home_module.dart';
import 'modules/tabs/tabs_module.dart';

class AppModule extends MainModule {
  @override
  List<Bind> get binds => [];

  @override
  List<Router> get routers => [
        Router("/home", module: TabsModule()),
        Router("/", module: HomeModule()),
      ];

  @override
  Widget get bootstrap => AppWidget();
}
