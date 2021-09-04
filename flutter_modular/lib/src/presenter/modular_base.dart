import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/src/domain/usecases/get_arguments.dart';
import 'package:modular_core/modular_core.dart';

import 'package:flutter_modular/src/domain/usecases/dispose_bind.dart';
import 'package:flutter_modular/src/domain/usecases/finish_module.dart';
import 'package:flutter_modular/src/domain/usecases/get_bind.dart';
import 'package:flutter_modular/src/domain/usecases/module_ready.dart';
import 'package:flutter_modular/src/domain/usecases/start_module.dart';
import 'package:triple/triple.dart';
import 'errors/errors.dart';
import 'models/modular_args.dart';
import 'models/modular_navigator.dart';
import 'models/module.dart';
import 'package:meta/meta.dart';

abstract class IModularBase {
  void destroy();
  Future<void> isModuleReady<M extends Module>();
  void init(Module module);
  String get initialRoute;
  ModularArguments get args;
  IModularNavigator get to;
  IModularNavigator? navigatorDelegate;
  void debugPrintModular(String text);
  Future<B> getAsync<B extends Object>({B? defaultValue});

  B get<B extends Object>({
    B? defaultValue,
  });

  bool dispose<B extends Object>();
}

class ModularBase implements IModularBase {
  final DisposeBind disposeBind;
  final FinishModule finishModule;
  final GetBind getBind;
  final GetArguments getArguments;
  final StartModule startModule;
  final IsModuleReady isModuleReadyUsecase;
  final IModularNavigator navigator;

  @override
  IModularNavigator? navigatorDelegate;

  bool _moduleHasBeenStarted = false;

  ModularBase(
      {required this.disposeBind,
      required this.getArguments,
      required this.finishModule,
      required this.getBind,
      required this.startModule,
      required this.isModuleReadyUsecase,
      required this.navigator});

  @override
  bool dispose<B extends Object>() => disposeBind<B>().getOrElse((left) => false);

  @override
  B get<B extends Object>({B? defaultValue}) {
    return getBind<B>().getOrElse((left) {
      if (defaultValue != null) {
        return defaultValue;
      }
      throw left;
    });
  }

  @override
  Future<B> getAsync<B extends Object>({B? defaultValue}) {
    return getBind<Future<B>>().getOrElse((left) {
      if (defaultValue != null) {
        return Future.value(defaultValue);
      }
      throw left;
    });
  }

  @override
  Future<void> isModuleReady<M extends Module>() => isModuleReadyUsecase.call<M>();

  @override
  void destroy() => finishModule();

  @visibleForTesting
  void disposeBindFunction(bindValue) {
    if (bindValue is Disposable) {
      bindValue.dispose();
    } else if (bindValue is Store) {
      bindValue.destroy();
    } else if (bindValue is Sink) {
      bindValue.close();
    } else if (bindValue is ChangeNotifier) {
      bindValue.dispose();
    }
  }

  @override
  void init(Module module) {
    if (!_moduleHasBeenStarted) {
      startModule(module).fold((l) => throw l, (r) => print('${module.runtimeType} started!'));
      _moduleHasBeenStarted = true;

      setDisposeResolver(disposeBindFunction);

      setPrintResolver(print);
    } else {
      throw ModuleStartedException('Module ${module.runtimeType} is already started');
    }
  }

  @override
  IModularNavigator get to => navigatorDelegate ?? navigator;

  @override
  ModularArguments get args => getArguments().getOrElse((l) => ModularArguments.empty());

  final flags = ModularFlags();

  @override
  void debugPrintModular(String text) {
    if (flags.isDebug) {
      print(text);
    }
  }

  @override
  final String initialRoute = '/';
}
