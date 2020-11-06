import 'package:flutter/foundation.dart';

import '../flutter_modular.dart';
import 'delegates/modular_router_delegate.dart';
import 'interfaces/modular_interface.dart';

ChildModule _initialModule;

class ModularImpl implements ModularInterface {
  final ModularRouterDelegate routerDelegate;
  final Map<String, ChildModule> injectMap;
  IModularNavigator navigatorDelegate;

  ModularImpl({
    this.routerDelegate,
    this.injectMap,
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
  void bindModule(ChildModule module, [String path]) {
    assert(module != null);
    final name = module.runtimeType.toString();
    if (!injectMap.containsKey(name)) {
      module.paths.add(path);
      injectMap[name] = module;
      module.instance();
      debugPrintModular("-- ${module.runtimeType.toString()} INITIALIZED");
    } else {
      injectMap[name].paths.add(path);
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
  IModularNavigator get link => throw UnimplementedError();

  @override
  bool get debugMode => !kReleaseMode;

  @override
  String get initialRoute => '/';

  @override
  B get<B>(
      {Map<String, dynamic> params,
      List<Type> typesInRequest,
      B defaultValue}) {
    if (B.toString() == 'dynamic') {
      throw ModularError('not allow for dynamic values');
    }

    typesInRequest ??= [];

    B result;

    if (typesInRequest.isEmpty) {
      final module = routerDelegate
          .currentConfiguration.currentModule.runtimeType
          .toString();
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

  B _getInjectableObject<B>(
    String tag, {
    Map<String, dynamic> params,
    List<Type> typesInRequest,
    bool checkKey = true,
  }) {
    B value;
    if (!checkKey) {
      value = injectMap[tag].getBind<B>(params, typesInRequest: typesInRequest);
    } else if (injectMap.containsKey(tag)) {
      value = injectMap[tag].getBind<B>(params, typesInRequest: typesInRequest);
    }

    return value;
  }

  @override
  void dispose<B>([String moduleName]) {
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
    return injectMap[tag].remove<B>();
  }
}
