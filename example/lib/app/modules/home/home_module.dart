import 'package:example/app/modules/home/pages/list/list_widget.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'guard/guard.dart';
import 'home_bloc.dart';
import 'home_widget.dart';

class HomeModule extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => HomeBloc()),
      ];

  @override
  List<Router> get routers => [
        Router(
          Modular.initialRoute,
          child: (_, args) => HomeWidget(),
        ),
        Router(
          "/list/:id",
          child: (_, args) => ListWidget(
            param: args.params['id'],
          ),
          guards: [MyGuard()],
        ),
      ];

  static Inject get to => Inject<HomeModule>.of();
}
