import 'package:flutter/widgets.dart';

import '../errors/errors.dart';
import '../inject/bind.dart';
import '../inject/inject.dart';
import '../interfaces/disposable.dart';
import '../models/modular_route.dart';

@immutable
abstract class ChildModule {
  late final List<Bind> binds;
  late final List<ModularRoute> routes;

  @visibleForTesting
  void changeBinds(List<Bind> b) {
    binds.clear();
    binds.addAll(b);
  }

  final List<String> paths = <String>[];

  final Map<Type, dynamic> _singletonBinds = {};

  T? getBind<T>(
      {Map<String, dynamic>? params, required List<Type> typesInRequest}) {
    T bindValue;
    var type = _getInjectType<T>();
    if (_singletonBinds.containsKey(type)) {
      bindValue = _singletonBinds[type];
      return bindValue;
    }

    var bind = binds.firstWhere((b) => b.inject is T Function(Inject),
        orElse: () => BindEmpty());
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

    bindValue =
        bind.inject(Inject(params: params, typesInRequest: typesInRequest));
    if (bind.singleton) {
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
    if (bind is Disposable || bind is ChangeNotifier) {
      bind.dispose();
      return;
    } else if (bind is Sink) {
      bind.close();
      return;
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
      if (!bindElement.lazy) {
        var b = bindElement.inject(Inject());
        _singletonBinds[b.runtimeType] = b;
      }
    }
  }
}
