import 'package:flutter_modular/flutter_modular.dart';

import 'tab2_bloc.dart';
import 'tab2_page.dart';

class Tab2Module extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => Tab2Bloc()),
      ];

  @override
  List<Router> get routers => [
        Router(Modular.initialRoute, child: (_, args) => Tab2Page()),
      ];
}
