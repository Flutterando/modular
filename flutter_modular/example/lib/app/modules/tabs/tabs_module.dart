import 'package:flutter_modular/flutter_modular.dart';

import 'tabs_bloc.dart';
import 'tabs_page.dart';

class TabsModule extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => TabsBloc()),
      ];

  @override
  List<Router> get routers => [
        Router('/', child: (_, args) => TabsPage()),
      ];
}
