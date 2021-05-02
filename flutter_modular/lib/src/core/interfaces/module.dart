import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:triple/triple.dart';

import '../../presenters/inject.dart';
import '../errors/errors.dart';
import '../models/bind.dart';
import 'disposable.dart';
import 'modular_route.dart';

class _ImmutableValue {
  var isReadyFlag = false;
}

@immutable
abstract class Module {
  final Map<Type, dynamic> _singletonBinds = {};

  final List<Bind> binds = [];
  final List<ModularRoute> routes = [];

  final List<Module> imports = [];
  final _immutableValue = _ImmutableValue();

  Module() {
    for (var module in imports) {
      for (var bind in module.binds.where((element) => element.export)) {
        binds.insert(0, bind);
      }
    }
  }

  Future<void> isReady() async {
    if (_immutableValue.isReadyFlag) return;
    final listResolvedBind = <Bind>[];
    for (var i = 0; i < binds.length; i++) {
      final bind = binds[i];
      if (bind is AsyncBind) {
        final resolvedBind = await bind.converToAsyncBind();
        listResolvedBind.add(resolvedBind);
      }
    }
    binds.insertAll(0, listResolvedBind);
    _immutableValue.isReadyFlag = true;
  }

  @visibleForTesting
  void changeBinds(List<Bind> b) {
    binds.clear();
    binds.addAll(b);
  }

  final List<String> paths = <String>[];

  T? getInjectedBind<T>([Type? type]) {
    type = type ?? _getInjectType<T>();
    if (_singletonBinds.containsKey(type)) {
      return _singletonBinds[type];
    } else {
      return null;
    }
  }

  T? getBind<T extends Object>({required List<Type> typesInRequest}) {
    T bindValue;
    var type = _getInjectType<T>();
    if (_singletonBinds.containsKey(type)) {
      bindValue = _singletonBinds[type];
      return bindValue;
    }

    var bind = binds.firstWhere((b) => b.inject is T Function(Inject), orElse: () => BindEmpty());
    if (bind is BindEmpty) {
      typesInRequest.remove(type);
      return null;
    }

    if (typesInRequest.contains(type)) {
      throw ModularError('''
Recursive calls detected. This can cause StackOverflow.
Check the Binds of the $runtimeType module:
***
${typesInRequest.join('\n')}
***
      
      ''');
    } else {
      typesInRequest.add(type);
    }

    bindValue = bind.inject(Inject(typesInRequest: typesInRequest)) as T;
    if (bind.isSingleton) {
      _singletonBinds[type] = bindValue;
    }

    typesInRequest.remove(type);
    return bindValue;
  }

  /// Dispose bind from the memory
  bool remove<T>() {
    final type = _getInjectType<T>();
    if (_singletonBinds.containsKey(type)) {
      var inject = _singletonBinds[type];
      _callDispose(inject);
      _singletonBinds.remove(type);
      return true;
    } else {
      return false;
    }
  }

  _callDispose(dynamic bind) {
    if (bind is Disposable) {
      bind.dispose();
    } else if (bind is ChangeNotifier) {
      bind.dispose();
    } else if (bind is Sink) {
      bind.close();
    } else if (bind is Store) {
      bind.destroy();
    }
  }

  /// Dispose all bind from the memory
  void cleanInjects() {
    for (final key in _singletonBinds.keys) {
      var _bind = _singletonBinds[key];
      _callDispose(_bind);
    }
    _singletonBinds.clear();
  }

  Type _getInjectType<B>() {
    var foundType = B;
    _singletonBinds.forEach((key, value) {
      if (value is B) {
        foundType = key;
      }
    });

    return foundType;
  }

  /// Create a instance of all binds isn't lazy Loaded
  void instance() {
    for (final bindElement in binds) {
      if (!bindElement.isLazy) {
        var b = bindElement.inject(Inject());
        _singletonBinds[b.runtimeType] = b;
      }
    }
  }
}
