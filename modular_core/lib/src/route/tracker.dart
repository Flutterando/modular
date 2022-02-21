import 'dart:async';

import 'package:meta/meta.dart';
import 'package:modular_interfaces/modular_interfaces.dart';

class TrackerImpl implements Tracker {
  @override
  final Injector injector;
  RouteContext? _nullableModule;
  @override
  RouteContext get module {
    if (_nullableModule != null) {
      return _nullableModule!;
    }

    throw TrackerNotInitiated('Execute Tracker.runApp()');
  }

  @visibleForTesting
  final routeMap = <ModularKey, ModularRoute>{};

  TrackerImpl(this.injector);

  var _arguments = ModularArguments.empty();
  @override
  ModularArguments get arguments => _arguments;

  @override
  String get currentPath => arguments.uri.toString();

  @override
  FutureOr<ModularRoute?> findRoute(String path,
      {dynamic data, String schema = ''}) async {
    var uri = _resolverPath(path);
    final modularKey = ModularKey(schema: schema, name: uri.path);

    ModularRoute? route;
    var params = <String, String>{};

    for (var key in routeMap.keys) {
      var uriCandidate = Uri.parse(key.name);
      if (uriCandidate.path == uri.path) {
        final candidate = routeMap[key];
        if (key.copyWith(name: uri.path) == modularKey) {
          route = candidate;
          break;
        }
      }
      if (uriCandidate.pathSegments.length != uri.pathSegments.length &&
          !uriCandidate.path.contains('**')) {
        continue;
      }

      if (!(uriCandidate.path.contains(':') ||
          uriCandidate.path.contains('**'))) {
        continue;
      }

      var result = _extractParams(uriCandidate, uri);
      if (result != null) {
        final candidate = routeMap[key];
        if (key.copyWith(name: uri.path) == modularKey) {
          route = candidate;
          params = result;
          break;
        }
      }
    }

    if (route == null) return null;

    route = route.copyWith(uri: uri);

    for (var middleware in route.middlewares) {
      route = await middleware.pre(route!);
      if (route == null) {
        break;
      }
    }

    if (route == null) return null;

    _arguments = ModularArguments(uri: uri, data: data, params: params);

    return route;
  }

  @override
  void reportPopRoute(ModularRoute route) {
    injector.disposeModuleByTag(route.uri.toString());
  }

  @override
  void reportPushRoute(ModularRoute route) {
    for (var module in [...route.bindContextEntries.values, module]) {
      injector.addBindContext(module, tag: route.uri.toString());
    }
  }

  Uri _resolverPath(String path) {
    return arguments.uri.resolve(path);
  }

  Map<String, String>? _extractParams(Uri candidate, Uri match) {
    final settledUrl = _processUrl(candidate.path);

    final regExp = RegExp("^$settledUrl\$", caseSensitive: true);
    final result = regExp.firstMatch(match.path);

    if (result != null) {
      final params = <String, String>{};
      for (var name in result.groupNames) {
        params[name] = result.namedGroup(name)!;
      }
      return params;
    } else {
      return null;
    }
  }

  String _processUrl(String url) {
    if (url.endsWith('**')) {
      return url.replaceFirst('**', '(?<w>.*)');
    }

    final newUrl = <String>[];
    for (var part in url.split('/')) {
      part = part.contains(":") ? "(?<${part.substring(1)}>.*)" : part;
      newUrl.add(part);
    }
    return newUrl.join("/");
  }

  @override
  void runApp(RouteContext module) {
    _nullableModule = module;
    injector.addBindContext(module, tag: '/');
    routeMap.addAll(module.init());
  }

  @override
  void reassemble() {
    routeMap.clear();
    routeMap.addAll(module.init());
    for (var childModule in module.modules) {
      injector.updateBinds(childModule);
    }
    injector.reassemble();
  }

  @override
  void finishApp() {
    injector.destroy();
    routeMap.clear();
    _nullableModule = null;
  }

  @override
  void setArguments(ModularArguments args) => _arguments = args;
}

class TrackerNotInitiated extends ModularError {
  const TrackerNotInitiated(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}
