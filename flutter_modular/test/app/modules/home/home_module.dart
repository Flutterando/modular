import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../guard/guard.dart';
import '../../shared/app_info.state.dart';
import '../forbidden/forbidden_widget.dart';
import '../product/product_module.dart';
import 'home_bloc.dart';
import 'home_widget.dart';

class HomeModule extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => AppState(), singleton: true),
        Bind((i) => HomeBloc(i())),
        Bind((i) => HomeBloc(i(defaultValue: AppBloc()))),
      ];

  @override
  List<ModularRouter> get routers => [
        ModularRouter(
          "/",
          child: (_, args) => HomeWidget(),
          transition: TransitionType.fadeIn,
        ),
        ModularRouter(
          "/forbidden2",
          child: (_, args) => ForbiddenWidget(),
          transition: TransitionType.fadeIn,
          guards: [MyGuard()],
        ),
        ModularRouter("/list/:id/:id2", child: (_, args) => HomeWidget()),
        ModularRouter("/product", module: ProductModule()),
        ModularRouter("/arguments", child: (_, args) => ArgumentsPage(id: args.data)),
        ModularRouter("/modularArguments", child: (_, args) => ModularArgumentsPage()),
      ];
}

class ArgumentsPage extends StatelessWidget {
  final int id;

  const ArgumentsPage({Key key, @required this.id}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("$id"),
      ),
    );
  }
}

class ModularArgumentsPage extends StatefulWidget {
  @override
  _ModularArgumentsPageState createState() => _ModularArgumentsPageState();
}

class _ModularArgumentsPageState extends State<ModularArgumentsPage> {
  int _id;

  @override
  void initState() {
    super.initState();
    _id = Modular.args.data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("$_id"),
      ),
    );
  }
}
