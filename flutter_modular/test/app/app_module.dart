import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'app_bloc.dart';
import 'app_widget.dart';
import 'guard/guard.dart';
import 'modules/forbidden/forbidden_widget.dart';
import 'modules/home/home_module.dart';
import 'modules/product/product_module.dart';
import 'shared/ilocal_repository.dart';
import 'shared/local_storage_shared.dart';

class AppModule extends MainModule {
  @override
  List<Bind> get binds => [
        Bind((i) => AppBloc()),
        Bind<ILocalStorage>((i) => LocalStorageSharePreference()),
      ];

  @override
  List<ModularRouter> get routers => [
        ModularRouter(
          "/forbidden",
          child: (_, args) => ForbiddenWidget(),
          transition: TransitionType.fadeIn,
        ),
        ModularRouter(
          "/",
          module: HomeModule(),
          transition: TransitionType.fadeIn,
        ),
        // ModularRouter("/home", module: HomeModule()),
        // ModularRouter("/prod", module: ProductModule()),
        // ModularRouter("/homeTwo", module: HomeModule(), guards: [MyGuard()]),
      ];

  @override
  Widget get bootstrap => AppWidget();
}
