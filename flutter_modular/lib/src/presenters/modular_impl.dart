import 'package:flutter/foundation.dart';

import '../core/errors/errors.dart';
import '../core/interfaces/child_module.dart';
import '../core/interfaces/modular_interface.dart';
import '../core/interfaces/modular_navigator_interface.dart';
import '../core/models/modular_arguments.dart';
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
  B get<B extends Object>({Map<String, dynamic> params = const {}, List<Type>? typesInRequestList, B? defaultValue}) {
    var typesInRequest = typesInRequestList ?? [];
    if (B.toString() == 'dynamic') {
      throw ModularError('not allow for dynamic values');
    }
    B? result;

    if (typesInRequest.isEmpty) {
      final module = routerDelegate.currentConfiguration?.currentModule?.runtimeType.toString() ?? '=global';
      result = _getInjectableObject<B>(module, params: params, typesInRequestList: typesInRequest);
    }

    if (result != null) {
      return result;
    }

    for (var key in injectMap.keys) {
      final value = _getInjectableObject<B>(key, params: params, typesInRequestList: typesInRequest, checkKey: false);
      if (value != null) {
        return value;
      }
    }

    if (result == null && defaultValue != null) {
      return defaultValue;
    }

    throw ModularError('${B.toString()} not found');
  }

  B? _getInjectableObject<B extends Object>(
    String tag, {
    Map<String, dynamic> params = const {},
    List<Type>? typesInRequestList,
    bool checkKey = true,
  }) {
    B? value;
    var typesInRequest = typesInRequestList ?? [];
    if (!checkKey) {
      value = injectMap[tag]?.getBind<B>(params: params, typesInRequest: typesInRequest);
    } else if (injectMap.containsKey(tag)) {
      value = injectMap[tag]?.getBind<B>(params: params, typesInRequest: typesInRequest);
    }

    return value;
  }

  @override
  bool dispose<B extends Object>() {
    var isDisposed = false;
    for (var key in injectMap.keys) {
      if (_removeInjectableObject<B>(key)) {
        isDisposed = true;
        break;
      }
    }

    return isDisposed;
  }

  bool _removeInjectableObject<B>(String tag) {
    return injectMap[tag]?.remove<B>() ?? false;
  }
}
