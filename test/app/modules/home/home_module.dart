import 'package:flutter_modular/flutter_modular.dart';

import '../../app_bloc.dart';
import '../../guard/guard.dart';
import '../forbidden/forbidden_widget.dart';
import '../product/product_module.dart';
import 'home_bloc.dart';
import 'home_widget.dart';

class HomeModule extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => HomeBloc(i.get<AppBloc>())),
      ];

  @override
  List<Router> get routers => [
        Router(
          "/",
          child: (_, args) => HomeWidget(),
          transition: TransitionType.fadeIn,
        ),
        Router(
          "/forbidden2",
          child: (_, args) => ForbiddenWidget(),
          transition: TransitionType.fadeIn,
        ),
        Router("/list/:id/:id2", child: (_, args) => HomeWidget()),
        Router("/product", module: ProductModule()),
      ];

  static Inject get to => Inject<HomeModule>.of();
}
