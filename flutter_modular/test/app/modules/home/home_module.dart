import 'package:flutter/widgets.dart' hide Router;

import 'package:flutter_modular/flutter_modular.dart';

import '../../app_bloc.dart';
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
          guards: [MyGuard()],
        ),
        Router("/list/:id/:id2", child: (_, args) => HomeWidget()),
        Router("/product", module: ProductModule()),
        Router("/arguments", child: (_, args) => ArgumentsPage(id: args.data)),
        Router("/modularArguments", child: (_, args) => ModularArgumentsPage()),
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
