import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/routers/router.dart';

abstract class ChildModule {
  List<Bind> _binds;
  List<Bind> get binds;
  List<Router> get routers;

  ChildModule() {
    _binds = binds;
  }

  changeBinds(List<Bind> b) {
    _binds = b;
  }

  final List<String> paths = List<String>();

  final Map<Type, dynamic> _injectBinds = {};

  getBind<T>(Map<String, dynamic> params, {List<Type> typesInRequest}) {
    T _bind;
    Type type = _getInjectType<T>();
    if (_injectBinds.containsKey(type)) {
      _bind = _injectBinds[type];
      return _bind;
    }

    Bind b = _binds.firstWhere((b) => b.inject is T Function(Inject),
        orElse: () => null);
    if (b == null) {
      typesInRequest.remove(type);
      return null;
    }

    if (typesInRequest.contains(type)) {
      throw ModularError('''
Recursive calls detected. This can cause StackOverflow.
Check the Binds of the ${this.runtimeType} module:
***
${typesInRequest.join('\n')}
***
      
      ''');
    } else {
      typesInRequest.add(type);
    }

    _bind = b.inject(Inject(
      params: params,
      typesInRequest: typesInRequest,
      //     tag: this.runtimeType.toString(),
    ));
    if (b.singleton) {
      _injectBinds[type] = _bind;
    }
    return _bind;
  }

  bool remove<T>() {
    Type type = _getInjectType<T>();
    if (_injectBinds.containsKey(type)) {
      var inject = _injectBinds[type];
      _callDispose(inject);
      _injectBinds.remove(type);
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
    } catch (e) {}
  }

  cleanInjects() {
    for (Type key in _injectBinds.keys) {
      var _bind = _injectBinds[key];
      _callDispose(_bind);
    }
    _injectBinds.clear();
  }

  Type _getInjectType<B>() {
    for (Type key in _injectBinds.keys) {
      if (key is B) {
        return key;
      }
    }
    return B;
  }

  void instance() {
    _binds.forEach((bindElement) {
      if (!bindElement.lazy) {
        var b = bindElement.inject(Inject());
        _injectBinds[b.runtimeType] = b;
      }
    });
  }
}
