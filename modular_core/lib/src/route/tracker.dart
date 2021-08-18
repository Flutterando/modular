import 'dart:async';

import 'package:modular_interfaces/modular_interfaces.dart';

import 'route_context.dart';

class TrackerImpl implements Tracker {
  final Injector injector;
  RouteContext? _nullableModule;
  RouteContext get module {
    if (_nullableModule != null) {
      return _nullableModule!;
    }

    throw TrackerNotInitiated('Execute Tracker.runApp()');
  }

  TrackerImpl(this.injector);

  var arguments = ModularArguments.empty();

  String get currentPath => arguments.uri.toString();

  FutureOr<ModularRoute?> findRoute(String path, {dynamic data, String schema = ''}) async {
    var uri = _resolverPath(path);
    final modularKey = ModularKey(schema: schema, name: uri.path);

    ModularRoute? route;
    var params = <String, String>{};

    for (var key in (module as RouteContextImpl).routeMap.keys) {
      var uriCandidate = Uri.parse(key.name);
      if (uriCandidate.path == uri.path) {
        final candidate = (module as RouteContextImpl).routeMap[key];
        if (key.copyWith(name: uri.path) == modularKey) {
          route = candidate;
          break;
        }
      }
      if (uriCandidate.pathSegments.length != uri.pathSegments.length) {
        continue;
      }

      if (!uriCandidate.path.contains(':')) {
        continue;
      }

      var result = _extractParams(uriCandidate, uri);
      if (result != null) {
        final candidate = (module as RouteContextImpl).routeMap[key];
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
      route = await middleware.call(route!);
      if (route == null) {
        break;
      }
    }

    if (route == null) return null;

    arguments = arguments.copyWith(data: data, uri: uri, params: params);
    _injectBindContext(route);
    return route;
  }

  void reportPopRoute(ModularRoute route) {
    injector.disposeModuleByTag(route.uri.toString());
  }

  Uri _resolverPath(String path) {
    return arguments.uri.resolve(path);
  }

  void _injectBindContext(ModularRoute route) {
    for (var module in [...route.bindContextEntries.values, module]) {
      injector.bindContext(module, tag: route.uri.toString());
    }
  }

  Map<String, String>? _extractParams(Uri candidate, Uri match) {
    final settledUrl = _processUrl(candidate.path);

    final regExp = RegExp("^${settledUrl}\$", caseSensitive: true);
    final result = regExp.firstMatch(match.path);

    if (result != null) {
      final params = <String, String>{};
      for (var name in result.groupNames) {
        params[name] = result.namedGroup(name)!;
      }
      return params;
    }
  }

  String _processUrl(String url) {
    final newUrl = <String>[];
    for (var part in url.split('/')) {
      part = part.contains(":") ? "(?<${part.substring(1)}>.*)" : part;
      newUrl.add(part);
    }
    return newUrl.join("/");
  }

  void runApp(RouteContext module) {
    _nullableModule = module;
    injector.bindContext(module, tag: '/');
  }

  void finishApp() {
    injector.destroy();
    _nullableModule = null;
  }
}

class TrackerNotInitiated implements NullThrownError {
  final String message;
  final StackTrace? stackTrace;

  const TrackerNotInitiated(this.message, [this.stackTrace]);

  @override
  String toString() {
    return ''' 
$runtimeType: $message

${stackTrace != null ? stackTrace : ''}
    ''';
  }
}
