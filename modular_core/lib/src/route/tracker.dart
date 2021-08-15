import 'package:modular_core/src/di/injector.dart';

import 'modular_arguments.dart';
import 'modular_route.dart';
import 'module.dart';

class Tracker {
  final Injector injector;
  Module? _nullableModule;
  Module get module {
    if (_nullableModule != null) {
      return _nullableModule!;
    }

    throw TrackerNotInitiated('Execute Tracker.runApp()');
  }

  Tracker(this.injector);

  var arguments = ModularArguments.empty();

  Uri _resolverPath(String path) {
    return arguments.uri.resolve(path);
  }

  ModularRoute? findRoute(String path, [dynamic data]) {
    var uri = _resolverPath(path);

    ModularRoute? route;
    var params = <String, String>{};

    for (var key in module.routeMap.keys) {
      var uriCandidate = Uri.parse(key);
      if (key == uri.path) {
        route = module.routeMap[key];
        break;
      }
      if (uriCandidate.pathSegments.length != uri.pathSegments.length) {
        continue;
      }

      final nomalizedCandidatePath = _prepareToRegex(uriCandidate.path);
      final regExp = RegExp("^${nomalizedCandidatePath}\$", caseSensitive: true);
      var result = regExp.firstMatch(uri.path);
      if (result != null) {
        var paramPos = 0;
        final candidateSegments = uriCandidate.pathSegments;
        final pathSegments = uri.pathSegments;

        for (var candidateSegment in candidateSegments) {
          if (candidateSegment.contains(":")) {
            var paramName = candidateSegment.replaceFirst(':', '');
            if (pathSegments[paramPos].isNotEmpty) {
              params[paramName] = pathSegments[paramPos];
            }
          }
          paramPos++;
        }
        route = module.routeMap[key];
      }
    }

    if (route == null) return null;
    arguments = arguments.copyWith(data: data, uri: uri, params: params);
    return route.copyWith(uri: uri);
  }

  // Map<String, String> _getParams() {
  //   var params = <String, String>{};
  // }

  String _prepareToRegex(String url) {
    final newUrl = <String>[];
    for (var part in url.split('/')) {
      var url = part.contains(":") ? "(.*?)" : part;
      newUrl.add(url);
    }

    return newUrl.join("/");
  }

  void runApp(Module module) {
    _nullableModule = module;
    injector.bindContext(module);
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
