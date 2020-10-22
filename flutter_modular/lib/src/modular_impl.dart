import 'package:flutter/foundation.dart';

import '../flutter_modular.dart';
import 'delegates/modular_router_delegate.dart';
import 'interfaces/modular_interface.dart';
import 'routers/modular_navigator.dart';

class ModularImpl implements ModularInterface {
  final ModularRouterDelegate routerDelegate;
  final Map<String, ChildModule> injectMap;
  final IModularNavigator navigatorDelegate;

  const ModularImpl(
      {this.routerDelegate, this.injectMap, this.navigatorDelegate});

  @override
  IModularNavigator get to {
    return navigatorDelegate ??
        ModularNavigator(routerDelegate.navigatorKey.currentState);
  }

  @override
  IModularNavigator get link => throw UnimplementedError();

  @override
  bool get debugMode => !kReleaseMode;

  @override
  String get initialRoute => '/';

  @override
  B get<B>(
      {Map<String, dynamic> params,
      String module,
      List<Type> typesInRequest,
      B defaultValue}) {
    if (B.toString() == 'dynamic') {
      throw ModularError('not allow for dynamic values');
    }

    typesInRequest ??= [];

    if (module != null) {
      return _getInjectableObject<B>(module,
          params: params, typesInRequest: typesInRequest);
    }

    for (var key in injectMap.keys) {
      final value = _getInjectableObject<B>(key,
          params: params,
          disableError: true,
          typesInRequest: typesInRequest,
          checkKey: false);
      if (value != null) {
        return value;
      }
    }

    if (defaultValue != null) {
      return defaultValue;
    }

    throw ModularError('${B.toString()} not found');
  }

  B _getInjectableObject<B>(
    String tag, {
    Map<String, dynamic> params,
    bool disableError = false,
    List<Type> typesInRequest,
    bool checkKey = true,
  }) {
    B value;
    if (!checkKey) {
      value = injectMap[tag].getBind<B>(params, typesInRequest: typesInRequest);
    } else if (injectMap.containsKey(tag)) {
      value = injectMap[tag].getBind<B>(params, typesInRequest: typesInRequest);
    }
    if (value == null && !disableError) {
      throw ModularError('${B.toString()} not found in module $tag');
    }

    return value;
  }

  @override
  void dispose<B>([String moduleName]) {
    if (B.toString() == 'dynamic') {
      throw ModularError('not allow for dynamic values');
    }

    if (moduleName != null) {
      _removeInjectableObject(moduleName);
    } else {
      for (var key in injectMap.keys) {
        if (_removeInjectableObject<B>(key)) {
          break;
        }
      }
    }
  }

  bool _removeInjectableObject<B>(String tag) {
    return injectMap[tag].remove<B>();
  }
}
