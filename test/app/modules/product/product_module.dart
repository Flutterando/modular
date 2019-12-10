import 'package:flutter_modular/flutter_modular.dart';

import 'product_bloc.dart';
import 'product_widget.dart';


class ProductModule extends ChildModule {
  @override
  List<Bind> get binds => [
    Bind((i) => ProductBloc()),
  ];

  @override
  List<Router> get routers => [
    Router("/", child: (_, args) => ProductWidget()),
  ];

  static Inject get to => Inject<ProductModule>.of();

}