import 'package:flutter/widgets.dart';

import '../../flutter_modular.dart';
import '../routers/router.dart';

abstract class ChildModule {
  List<Bind> _binds;
  List<Bind> get binds;
  List<Router> get routers;

  ChildModule() {
    _binds = binds;
  }

  void changeBinds(List<Bind> b) {
    _binds = b;
  }

  final List<String> paths = <String>[];

  final Map<Type, dynamic> _singletonBinds = {};

  T getBind<T>(Map<String, dynamic> params, {List<Type> typesInRequest}) {
    T bindValue;
    var type = _getInjectType<T>();
    if (_singletonBinds.containsKey(type)) {
      bindValue = _singletonBinds[type];
      return bindValue;
    }

    var bind = _binds.firstWhere((b) => b.inject is T Function(Inject),
        orElse: () => null);
    if (bind == null) {
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

    try {
      bind?.dispose();
    } on Exception {} 
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
    for (final key in _singletonBinds.keys) {
      if (key is B) {
        return key;
      }
    }
    return B;
  }

  /// Create a instance of all binds isn't lazy Loaded
  void instance() {
    for (final bindElement in _binds) {
      if (!bindElement.lazy) {
        var b = bindElement.inject(Inject());
        _singletonBinds[b.runtimeType] = b;
      }
    }
  }
}
