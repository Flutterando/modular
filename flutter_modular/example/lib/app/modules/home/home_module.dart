import 'package:example/app/modules/home/pages/list/list_widget.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/material.dart';
import 'guard/guard.dart';
import 'home_bloc.dart';
import 'home_widget.dart';

class SlowerPageRoute extends MaterialPageRoute {
  @override
  Duration get transitionDuration => Duration(milliseconds: 1200);

  Map eventP;
  SlowerPageRoute({
    @required builder,
    @required settings,
  }) : super(builder: builder, settings: settings);
}

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
          routeGenerator: (b, s) => SlowerPageRoute(builder: b, settings: s),
          child: (_, args) => ListWidget(
            param: int.parse(args.params['id']),
          ),
          guards: [MyGuard()],
        ),
      ];
}
