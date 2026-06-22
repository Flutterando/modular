import 'package:example/app/args/args_module.dart';
import 'package:example/app/checkout/checkout_module.dart';
import 'package:example/app/dashboard/dashboard_module.dart';
import 'package:example/app/home/home_page.dart';
import 'package:example/app/products/products_module.dart';
import 'package:example/app/settings/settings_module.dart';
import 'package:flutter_modular/flutter_modular.dart';

final homeModule = createModule(
  path: '/home',
  register: (c) {
    c
      ..route('/', child: (ctx, state) => const HomePage())
      ..module(productsModule)
      ..module(settingsModule)
      ..module(argsModule)
      ..module(checkoutModule)
      ..module(dashboardModule);
  },
);
