import 'package:flutter/foundation.dart';

import '../core/errors/errors.dart';
import '../core/interfaces/modular_interface.dart';
import '../core/interfaces/modular_navigator_interface.dart';
import '../core/interfaces/module.dart';
import '../core/models/bind.dart';
import '../core/models/modular_arguments.dart';
import 'inject.dart';
import 'modular_base.dart';
import 'navigation/modular_router_delegate.dart';

late Module _initialModule;

class ModularImpl implements ModularInterface {
  final ModularRouterDelegate routerDelegate;
  final Map<String, Module> injectMap;
  final ModularFlags flags;

  @override
  void setPathInActiveModules(String currentValue, String newValue) {
    for (var module in injectMap.values) {
      if (module.paths.contains(currentValue)) {
        module.paths.remove(currentValue);
        module.paths.add(newValue);
      }
    }
  }

  @override
  IModularNavigator? navigatorDelegate;

  List<Bind>? _overrideBinds;

  @override
  void overrideBinds(List<Bind> binds) {
    _overrideBinds = binds;
  }

  @override
  ModularArguments? get args => routerDelegate.args;

  ModularImpl({
    required this.flags,
    required this.routerDelegate,
    required this.injectMap,
  });

  @override
  Module get initialModule => _initialModule;

  @override
  void debugPrintModular(String text) {
    if (Modular.debugMode) {
      debugPrint(text);
    }
  }

  List<dynamic> _getAllSingletons() {
    final list = <dynamic>[];
    for (var key in injectMap.keys) {
      final module = injectMap[key]!;
      list.addAll(module.instanciatedSingletons);
    }
    return list;
  }

  @override
  void bindModule(Module module, {String path = '', bool rebindDuplicates = false}) {
    final name = module.runtimeType.toString();
    if (!injectMap.containsKey(name)) {
      injectMap[name] = module;
      injectMap[name]!.paths.add(path);
      injectMap[name]!.instance(_getAllSingletons());
      debugPrintModular("-- ${module.runtimeType.toString()} INITIALIZED");
      return;
    } else {
      // The same module with default path, so rebind the module
      if (path.isEmpty && rebindDuplicates) {
        final oldModule = injectMap[name];

        // Remove old injects
        oldModule?.cleanInjects();
        injectMap.remove(name);

        // Install new injects
        bindModule(module, path: name, rebindDuplicates: false);
        return;
      }

      if (injectMap[name]?.paths.isNotEmpty == true && injectMap[name]?.paths.last != path) {
        injectMap[name]?.paths.add(path);
      }
    }
  }

  @override
  void init(Module module) {
    _initialModule = module;
    bindModule(module, path: module.runtimeType.toString());
  }

  @override
  IModularNavigator get to => navigatorDelegate ?? routerDelegate;

  @override
  bool get debugMode => !kReleaseMode;

  @override
  String get initialRoute => '/';

  B? _findExistingInstance<B extends Object>() {
    for (var module in injectMap.values) {
      final bind = module.getInjectedBind<B>();
      if (bind != null) {
        return bind;
      }
    }
    return null;
  }

  @override
  Future<B> getAsync<B extends Object>({List<Type>? typesInRequestList}) async {
    final bind = get<Future<B>>(typesInRequestList: typesInRequestList);
    return await bind;
  }

  @override
  B get<B extends Object>({List<Type>? typesInRequestList, B? defaultValue}) {
    var typesInRequest = typesInRequestList ?? [];
    if (Modular.flags.experimentalNotAllowedParentBinds) {
      final module = routerDelegate.currentConfiguration?.currentModule?.runtimeType.toString() ?? 'AppModule';
      var bind = injectMap[module]!.binds.firstWhere((b) => b.inject is B Function(Inject), orElse: () => BindEmpty());
      if (bind is BindEmpty) {
        bind = injectMap[module]!.binds.firstWhere((b) => b.inject is Future<B> Function(Inject), orElse: () => BindEmpty());
      }

      if (bind is BindEmpty) {
        throw ModularError('\"${B.toString()}\" not found in \"$module\" module');
      }
    }
    var result = _findExistingInstance<B>();

    if (result != null) {
      return result;
    }

    for (var key in injectMap.keys) {
      final value = _getInjectableObject<B>(key, typesInRequestList: typesInRequest, checkKey: false);
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
    List<Type>? typesInRequestList,
    bool checkKey = true,
  }) {
    B? value;
    var typesInRequest = typesInRequestList ?? [];
    if (!checkKey || injectMap.containsKey(tag)) {
      value = injectMap[tag]?.getBind<B>(typesInRequest: typesInRequest);
    }

    return value;
  }

  @override
  bool dispose<B extends Object>() {
    var isDisposed = false;

    /// Logic to check if bind is in the injectMap
    /// Cause true -> continue the normal flow
    /// Otherwise -> returns true to don't make dispose again
    var check = false;

    for (var key in injectMap.keys) {
      if (check) break;

      final _binds = injectMap[key]?.binds ?? [];

      for (var element in _binds) {
        if (element.inject is B Function(Inject<dynamic>)) {
          check = true;
          break;
        }
      }
    }

    if (!check) return true;

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

  @override
  T bind<T extends Object>(Bind<T> bind) => Inject(overrideBinds: _overrideBinds ?? []).get(bind);

  @override
  Future<void> isModuleReady<M>() {
    if (injectMap.containsKey(M.toString())) {
      return injectMap[M.toString()]!.isReady();
    }
    throw ModularError('Module not exist in injector system');
  }
}
