import 'package:flutter/foundation.dart';
import 'package:flutter_modular/src/core/errors/errors.dart';
import 'package:flutter_modular/src/core/models/modular_arguments.dart';
import 'package:flutter_modular/src/core/modules/child_module.dart';

import 'interfaces/modular_interface.dart';
import 'interfaces/modular_navigator_interface.dart';
import 'modular_base.dart';
import 'navigation/modular_router_delegate.dart';

late ChildModule _initialModule;

class ModularImpl implements ModularInterface {
  final ModularRouterDelegate routerDelegate;
  final Map<String, ChildModule> injectMap;
  IModularNavigator? navigatorDelegate;

  @override
  ModularArguments? get args => routerDelegate.currentConfiguration?.args;

  ModularImpl({
    required this.routerDelegate,
    required this.injectMap,
    this.navigatorDelegate,
  });

  @override
  ChildModule get initialModule => _initialModule;

  @override
  void debugPrintModular(String text) {
    if (Modular.debugMode) {
      debugPrint(text);
    }
  }

  @override
  void bindModule(ChildModule module, [String path = '']) {
    final name = module.runtimeType.toString();
    if (!injectMap.containsKey(name)) {
      module.paths.add(path);
      injectMap[name] = module;
      module.instance();
      debugPrintModular("-- ${module.runtimeType.toString()} INITIALIZED");
    } else {
      injectMap[name]?.paths.add(path);
    }
  }

  @override
  void init(ChildModule module) {
    _initialModule = module;
    bindModule(module, "global==");
  }

  @override
  IModularNavigator get to => navigatorDelegate ?? routerDelegate;

  @override
  bool get debugMode => !kReleaseMode;

  @override
  String get initialRoute => '/';

  @override
  B get<B>(
      {Map<String, dynamic> params = const {},
      List<Type> typesInRequest = const [],
      B? defaultValue}) {
    if (B.toString() == 'dynamic') {
      throw ModularError('not allow for dynamic values');
    }
    B? result;

    if (typesInRequest.isEmpty) {
      final module = routerDelegate
              .currentConfiguration?.currentModule.runtimeType
              .toString() ??
          '=global';
      result = _getInjectableObject<B>(module,
          params: params, typesInRequest: typesInRequest);
    }

    if (result != null) {
      return result;
    }

    for (var key in injectMap.keys) {
      final value = _getInjectableObject<B>(key,
          params: params, typesInRequest: typesInRequest, checkKey: false);
      if (value != null) {
        return value;
      }
    }

    if (result == null && defaultValue != null) {
      return defaultValue;
    }

    throw ModularError('${B.toString()} not found');
  }

  B? _getInjectableObject<B>(
    String tag, {
    Map<String, dynamic> params = const {},
    List<Type> typesInRequest = const [],
    bool checkKey = true,
  }) {
    B? value;
    if (!checkKey) {
      value = injectMap[tag]
          ?.getBind<B>(params: params, typesInRequest: typesInRequest);
    } else if (injectMap.containsKey(tag)) {
      value = injectMap[tag]
          ?.getBind<B>(params: params, typesInRequest: typesInRequest);
    }

    return value;
  }

  @override
  void dispose<B>() {
    if (B.toString() == 'dynamic') {
      throw ModularError('not allow for dynamic values');
    }

    for (var key in injectMap.keys) {
      if (_removeInjectableObject<B>(key)) {
        break;
      }
    }
  }

  bool _removeInjectableObject<B>(String tag) {
    return injectMap[tag]?.remove<B>() ?? false;
  }
}
