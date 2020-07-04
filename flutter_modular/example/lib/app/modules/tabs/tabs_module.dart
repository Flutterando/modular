import 'package:example/app/modules/tabs/tabs_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:example/app/modules/tabs/tabs_page.dart';

class TabsModule extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => TabsBloc()),
      ];

  @override
  List<Router> get routers => [
        Router('/', child: (_, args) => TabsPage()),
      ];

  static Inject get to => Inject<TabsModule>.of();
}
