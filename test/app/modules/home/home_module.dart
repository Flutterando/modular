import 'package:flutter_modular/flutter_modular.dart';

import '../product/product_module.dart';
import 'home_bloc.dart';
import 'home_widget.dart';

class HomeModule extends ChildModule {
  @override
  List<Bind> get binds => [
    Bind((i) => HomeBloc()),
  ];

  @override
  List<Router> get routers => [
    Router("/", child: (_, args) => HomeWidget(), transition: TransitionType.fadeIn,),
    Router("/list/:id/:id2", child: (_, args) => HomeWidget()),
    Router("/product", module: ProductModule()),
  ];

  static Inject get to => Inject<HomeModule>.of();

}