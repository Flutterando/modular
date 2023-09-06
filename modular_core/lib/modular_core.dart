library modular_core;

import 'dart:async';

import 'package:auto_injector/auto_injector.dart';
import 'package:characters/characters.dart';
import 'package:meta/meta.dart';

import 'src/binds/tracker_injector.dart';

export 'package:auto_injector/auto_injector.dart';

// errors
part 'src/errors/errors.dart';
// di
part 'src/module/disposable.dart';
// modules
part 'src/module/module.dart';
// route
part 'src/route/arguments.dart';
part 'src/route/middleware.dart';
part 'src/route/route.dart';
part 'src/route/route_manager.dart';
part 'src/tracker.dart';

void Function(String text)? printResolverFunc;

void setPrintResolver(void Function(String text) fn) {
  printResolverFunc = fn;
}
