import 'package:example/app/modules/shopping/pages/page3/page3_bloc.dart';
import 'package:example/app/modules/shopping/pages/page2/page2_bloc.dart';
import 'package:example/app/modules/shopping/pages/page1/page1_bloc.dart';
import 'package:example/app/modules/shopping/shopping_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:example/app/modules/shopping/shopping_page.dart';

class ShoppingModule extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => Page3Bloc()),
        Bind((i) => Page2Bloc()),
        Bind((i) => Page1Bloc()),
        Bind((i) => ShoppingBloc()),
      ];

  @override
  List<Router> get routers => [
        Router('/', child: (_, args) => ShoppingPage()),
      ];

  static Inject get to => Inject<ShoppingModule>.of();
}
