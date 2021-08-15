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

    throw TrackerNotInitiate('Execute Tracker.runApp()');
  }

  Tracker(this.injector);

  var args = ModularArguments.empty();

  Uri get uri => args.uri;

  String _resolverPath(String path) {
    return '${uri.resolve(path).toString()}';
  }

  ModularRoute? findRoute(String path) {
    path = _resolverPath(path);
    final route = module.routeMap[path];
    return route?.copyWith(uri: uri);
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

class TrackerNotInitiate implements NullThrownError {
  final String message;
  final StackTrace? stackTrace;

  const TrackerNotInitiate(this.message, [this.stackTrace]);

  @override
  String toString() {
    return ''' 
$runtimeType: $message

${stackTrace != null ? stackTrace : ''}
    ''';
  }
}
