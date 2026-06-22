import 'package:example/app/home/home_module.dart';
import 'package:example/core/core_module.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// THE ROOT MODULE — composition. This file is the app's whole coupling map:
/// which modules exist and how they connect. In Flutter the coupling factors
/// are DI + Routes, and a Module makes exactly those visible. Each module
/// declares its OWN `path` (or none, for shared DI), so there is no `at:` here.
final appModule = createModule(
  register: (c) {
    c
      ..module(coreModule)
      ..module(homeModule);
  },
);
