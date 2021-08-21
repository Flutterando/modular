import 'package:meta/meta.dart';
import 'package:modular_core/modular_core.dart';
import 'package:modular_interfaces/modular_interfaces.dart';
import 'resolvers.dart';

class _MutableValue {
  var isReadyFlag = false;
}

class SingletonBind<T extends Object> {
  final BindContract<T> bind;
  final T value;

  SingletonBind({required this.bind, required this.value});
}

abstract class BindContextImpl implements BindContext {
  @visibleForOverriding
  List<BindContract> get binds => const [];
  @visibleForOverriding
  List<BindContext> get imports => const [];

  final _mutableValue = _MutableValue();

  final List<BindContract> _binds = [];
  @internal
  final Set<String> tags = {};
  final _singletonBinds = <Type, SingletonBind>{};
  List<dynamic> get instanciatedSingletons => _singletonBinds.values.map((e) => e.value).toList();

  BindContextImpl() {
    _binds.addAll(binds);
    for (var module in imports) {
      _addExportBinds((module as BindContextImpl)._binds);
    }
  }

  void _addExportBinds(List<BindContract> bindsForOtherModule) {
    final filteredList = bindsForOtherModule.where((element) => element.export);
    _binds.insertAll(0, filteredList);
  }

  T? getBind<T extends Object>(Injector injector) {
    T bindValue;
    var type = _getInjectType<T>();
    if (_singletonBinds.containsKey(type)) {
      bindValue = _singletonBinds[type]!.value as T;
      return bindValue;
    }

    var bind = _binds.firstWhere((b) => b.factoryFunction is T Function(Injector), orElse: () => BindEmpty());
    if (bind is BindEmpty) {
      return null;
    }

    bindValue = bind.factoryFunction(injector) as T;
    if (bind.isSingleton) {
      _singletonBinds[type] = SingletonBind(value: bindValue, bind: bind);
    }

    return bindValue;
  }

  @mustCallSuper
  bool remove<T>() {
    final type = _getInjectType<T>();
    if (_singletonBinds.containsKey(type)) {
      var singletonBind = _singletonBinds[type]!.value;
      disposeResolverFunc?.call(singletonBind);
      _singletonBinds.remove(type);
      return true;
    } else {
      return false;
    }
  }

  void removeScopedBind() {
    _singletonBinds.removeWhere((key, bind) {
      if (bind.bind.isScoped) {
        disposeResolverFunc?.call(bind);
        return true;
      }
      return false;
    });
  }

  @mustCallSuper
  void dispose() {
    for (final key in _singletonBinds.keys) {
      var _bind = _singletonBinds[key];
      disposeResolverFunc?.call(_bind);
    }
    _singletonBinds.clear();
  }

  @mustCallSuper
  void instantiateSingletonBinds(List<dynamic> singletons, Injector injector) {
    final filteredList = _binds.where((bind) => !bind.isLazy || !_containBind(singletons, bind));
    for (final bindElement in filteredList) {
      var b = bindElement.factoryFunction(injector);
      _singletonBinds[b.runtimeType] = SingletonBind(value: b, bind: bindElement);
    }
  }

  @mustCallSuper
  Future<void> isReady() async {
    if (_mutableValue.isReadyFlag) return;
    _mutableValue.isReadyFlag = true;
    final asyncBindList = _binds.whereType<AsyncBind>().toList();
    for (var bind in asyncBindList) {
      final resolvedBind = await bind.converToAsyncBind();
      _binds.insert(0, resolvedBind);
    }
  }

  bool _containBind(List<dynamic> singletons, BindContract bind) {
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
