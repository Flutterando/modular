import 'package:meta/meta.dart';
import 'bind.dart';
import 'injector.dart';
import 'resolvers.dart';

abstract class BindContext {
  final List<Bind> _binds = [];
  List<Bind> get binds => const [];
  final Set<String> tags = {};
  final _singletonBinds = <Type, dynamic>{};
  List<BindContext> get imports => const [];
  List<dynamic> get instanciatedSingletons => _singletonBinds.values.toList();

  @visibleForTesting
  List<Bind> getProcessBinds() => _binds;

  BindContext() {
    _binds.addAll(binds);
    for (var module in imports) {
      _addExportBinds(module._binds);
    }
  }

  void _addExportBinds(List<Bind> binds) {
    final filteredList = binds.where((element) => element.export);
    _binds.insertAll(0, filteredList);
  }

  T? getBind<T extends Object>() {
    T bindValue;
    var type = _getInjectType<T>();
    if (_singletonBinds.containsKey(type)) {
      bindValue = _singletonBinds[type];
      return bindValue;
    }

    var bind = _binds.firstWhere((b) => b.factoryFunction is T Function(Injector), orElse: () => BindEmpty());
    if (bind is BindEmpty) {
      return null;
    }

    bindValue = bind.factoryFunction(Injector.instance) as T;
    if (bind.isSingleton) {
      _singletonBinds[type] = bindValue;
    }

    return bindValue;
  }

  /// Dispose bind from the memory
  bool remove<T>() {
    final type = _getInjectType<T>();
    if (_singletonBinds.containsKey(type)) {
      var singletonBind = _singletonBinds[type];
      disposeResolverFunc?.call(singletonBind);
      _singletonBinds.remove(type);
      return true;
    } else {
      return false;
    }
  }

  /// Dispose all bind from the memory
  void dispose() {
    for (final key in _singletonBinds.keys) {
      var _bind = _singletonBinds[key];
      disposeResolverFunc?.call(_bind);
    }
    _singletonBinds.clear();
  }

  void instantiateSingletonBinds(List<dynamic> singletons) {
    final filteredList = _binds.where((bind) => !bind.isLazy || !_containBind(singletons, bind));
    for (final bindElement in filteredList) {
      var b = bindElement.factoryFunction(Injector.instance);
      _singletonBinds[b.runtimeType] = b;
    }
  }

  bool _containBind(List<dynamic> singletons, Bind bind) {
    return singletons.indexWhere((element) => _existBind(element, bind.factoryFunction)) >= 0;
  }

  bool _existBind<T>(T instance, T Function(Injector<dynamic>) inject) {
    return inject is T Function(Injector);
  }

  Type _getInjectType<B>() {
    var foundType = B;

    for (var value in _singletonBinds.values) {
      if (value is B) {
        foundType = _singletonBinds.entries.firstWhere((map) => map.value == value).key;
        break;
      }
    }

    return foundType;
  }
}
