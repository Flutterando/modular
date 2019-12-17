import 'package:example/app/modules/home/pages/list/list_widget.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'home_bloc.dart';
import 'home_widget.dart';

class HomeModule extends ChildModule {
  @override
  List<Bind> get binds => [
    Bind((i) => HomeBloc()),
  ];

  @override
  List<Router> get routers => [
    Router("/:id/:id2", child: (_, args) => HomeWidget()),
    Router("/list", child: (_, args) => ListWidget()),
    Router("/again", module: HomeModule()),
    Router("/list/:id", child: (_, args) => ListWidget(param: args.params['id'],)),
  ];

  static Inject get to => Inject<HomeModule>.of();

}