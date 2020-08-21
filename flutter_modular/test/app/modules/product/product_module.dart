import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'product_bloc.dart';

class ProductModule extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => ProductBloc()),
      ];

  @override
  List<ModularRouter> get routers => [
        ModularRouter("/:test", child: (_, args) => DetailsPage(id: 1)),
        ModularRouter("/product", child: (_, args) => ProductPage()),
      ];
}

class DetailsPage extends StatelessWidget {
  final int id;

  const DetailsPage({Key key, this.id}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
