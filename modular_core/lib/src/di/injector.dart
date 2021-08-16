import 'bind.dart';
import 'bind_context.dart';
import 'resolvers.dart';
import 'package:characters/characters.dart';

class Injector<T> {
  final _allBindContexts = <Type, BindContext>{};

  B call<B extends Object>([Bind<B>? bind]) => get<B>(bind);

  B get<B extends Object>([Bind<B>? bind]) {
    B? bind;

    for (var module in _allBindContexts.values) {
      bind = module.getBind<B>();
      if (bind != null) {
        break;
      }
    }

    if (bind != null) {
      return bind;
    } else {
      throw BindNotFound();
    }
  }

  bool isModuleAlive<T extends BindContext>() => _allBindContexts.containsKey(_getType<T>());

  void bindContext(BindContext module, {String tag = ''}) {
    final typeModule = module.runtimeType;
    if (!_allBindContexts.containsKey(typeModule)) {
      module.instantiateSingletonBinds(_getAllSingletons());
      module.tags.add(tag);
      _allBindContexts[typeModule] = module;
      printResolverFunc?.call("-- $typeModule INITIALIZED");
    } else {
      _allBindContexts[typeModule]?.tags.add(tag);
    }
  }

  void disposeModuleByTag(String tag) {
    final trash = <Type>[];

    for (var key in _allBindContexts.keys) {
      final module = _allBindContexts[key]!;

      module.tags.remove(tag);
      if (tag.characters.last == '/') {
        module.tags.remove('$tag/'.replaceAll('//', ''));
      }
      if (module.tags.isEmpty) {
        module.dispose();
        trash.add(key);
      }
    }

    for (final key in trash) {
      _allBindContexts.remove(key);
      printResolverFunc?.call("-- $key DISPOSED");
    }
  }

  bool dispose<B extends Object>() {
    for (var binds in _allBindContexts.values) {
      final r = binds.remove<B>();
      if (r) return r;
    }
    return false;
  }

  void destroy() {
    for (var binds in _allBindContexts.values) {
      binds.dispose();
    }
    _allBindContexts.clear();
  }

  void removeBindContext<T extends BindContext>() {
    final module = _allBindContexts.remove(_getType<T>());
    if (module != null) {
      module.dispose();
      printResolverFunc?.call("-- ${module.runtimeType} DISPOSED");
    }
  }

  Type _getType<T>() => T;

  List<dynamic> _getAllSingletons() {
    final list = <dynamic>[];
    for (var module in _allBindContexts.values) {
      list.addAll(module.instanciatedSingletons);
    }
    return list;
  }
}

class BindNotFound implements Exception {
  @override
  String toString() {
    return 'BindNotFound';
  }
}
