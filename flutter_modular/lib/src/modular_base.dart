import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../flutter_modular.dart';
import 'delegates/modular_route_information_parser.dart';
import 'delegates/modular_router_delegate.dart';
import 'interfaces/child_module.dart';
import 'interfaces/modular_interface.dart';
import 'interfaces/route_guard.dart';
import 'modular_impl.dart';
import 'routers/modular_navigator.dart';
import 'routers/modular_router.dart';
import 'utils/modular_arguments.dart';
import 'utils/old.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

final routeInformationParser = ModularRouteInformationParser();
final routerDelegate = ModularRouterDelegate(_navigatorKey);
const Map<String, ChildModule> _injectMap = {};
// ignore: non_constant_identifier_names
final ModularInterface Modular =
    ModularImpl(routerDelegate: routerDelegate, injectMap: _injectMap);

extension ModularExtension on MaterialApp {
  MaterialApp modular() {
    final app = MaterialApp.router(
      key: key,
      scaffoldMessengerKey: scaffoldMessengerKey,
      routeInformationProvider: routeInformationProvider,
      backButtonDispatcher: backButtonDispatcher,
      builder: builder,
      title: title,
      onGenerateTitle: onGenerateTitle,
      color: color,
      theme: theme,
      darkTheme: darkTheme,
      highContrastTheme: highContrastTheme,
      highContrastDarkTheme: highContrastDarkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: localizationsDelegates,
      localeListResolutionCallback: localeListResolutionCallback,
      localeResolutionCallback: localeResolutionCallback,
      supportedLocales: supportedLocales,
      debugShowMaterialGrid: debugShowMaterialGrid,
      showPerformanceOverlay: showPerformanceOverlay,
      checkerboardRasterCacheImages: checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: checkerboardOffscreenLayers,
      showSemanticsDebugger: showSemanticsDebugger,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      shortcuts: shortcuts,
      actions: actions,
      restorationScopeId: restorationScopeId,
      routeInformationParser: routeInformationParser,
      routerDelegate: routerDelegate,
    );

    return app;
  }
}

_debugPrintModular(String text) {
  if (Modular.debugMode) {
    debugPrint(text);
  }
}

// class _Modular {
//   static ChildModule _initialModule;
//   static ModularArguments _args;
//   static ModularArguments get args => _args?.copy();
//   static List<String> currentModule = <String>[];
//   static final Map<String, GlobalKey<NavigatorState>> _navigators =
//       <String, GlobalKey<NavigatorState>>{};

//   static void init(ChildModule module) {
//     _initialModule = module;
//     bindModule(module, "global==");
//   }

//   @visibleForTesting
//   static void bindModule(ChildModule module, [String path]) {
//     assert(module != null);
//     final name = module.runtimeType.toString();
//     if (!_injectMap.containsKey(name)) {
//       module.paths.add(path);
//       _injectMap[name] = module;
//       module.instance();
//       _debugPrintModular("-- ${module.runtimeType.toString()} INITIALIZED");
//     } else {
//       _injectMap[name].paths.add(path);
//     }
//   }

//   static void removeModule(ChildModule module, [String name]) {
//     name ??= module.runtimeType.toString();
//     if (_injectMap.containsKey(name)) {
//       _injectMap[name].cleanInjects();
//       _injectMap.remove(name);
//       if (_navigators.containsKey(name)) {
//         _navigators.remove(name);
//         currentModule.remove(name);
//       }
//     }
//   }

//   @visibleForTesting
//   static String prepareToRegex(String url) {
//     final newUrl = <String>[];
//     for (var part in url.split('/')) {
//       var url = part.contains(":") ? "(.*?)" : part;
//       newUrl.add(url);
//     }

//     return newUrl.join("/");
//   }

//   @visibleForTesting
//   static dynamic convertType(String value) {
//     if (int.tryParse(value) != null) {
//       return int.parse(value);
//     } else if (double.tryParse(value) != null) {
//       return double.parse(value);
//     } else if (value.toLowerCase() == 'true') {
//       return true;
//     } else if (value.toLowerCase() == 'false') {
//       return false;
//     }

//     return value;
//   }

//   @visibleForTesting
//   static bool searchRoute(
//       ModularRouter router, String routeNamed, String path) {
//     if (routeNamed.split('/').length != path.split('/').length) {
//       return false;
//     }

//     if (routeNamed.contains('/:')) {
//       final regExp = RegExp(
//         "^${prepareToRegex(routeNamed)}\$",
//         caseSensitive: true,
//       );
//       var r = regExp.firstMatch(path);
//       if (r != null) {
//         final params = <String, String>{};
//         var paramPos = 0;
//         final routeParts = routeNamed.split('/');
//         final pathParts = path.split('/');

//         //  print('Match! Processing $path as $routeNamed');

//         for (var routePart in routeParts) {
//           if (routePart.contains(":")) {
//             var paramName = routePart.replaceFirst(':', '');
//             if (pathParts[paramPos].isNotEmpty) {
//               params[paramName] = pathParts[paramPos];
//               routeNamed =
//                   routeNamed.replaceFirst(routePart, params[paramName]);
//             }
//           }
//           paramPos++;
//         }

//         // print('Result processed $path as $routeNamed');

//         if (routeNamed != path) {
//           router.params = null;
//           return false;
//         }

//         router.params = params;
//         return true;
//       }

//       router.params = null;
//       return false;
//     }

//     return routeNamed == path;
//   }

//   static RouteGuard _verifyGuard(List<RouteGuard> guards, String path) {
//     RouteGuard guard;
//     var realGuards = guards ?? [];
//     guard = realGuards.length == 0
//         ? null
//         : guards.firstWhere((guard) => !guard.canActivate(path),
//             orElse: () => null);

//     realGuards
//         .expand((c) => c.executors)
//         .forEach((c) => c.onGuarded(path, isActive: guard == null));

//     if (guard != null) {
//       throw ModularError("Path guarded : $path");
//     }
//     return guard;
//   }

//   static List<RouteGuard> _masterRouteGuards;

//   static ModularRouter _searchInModule(
//       ChildModule module, String routerName, String path) {
//     path = "/$path".replaceAll('//', '/');
//     final routers = module.routers;
//     routers.sort((preview, actual) {
//       return preview.routerName.contains('/:') ? 1 : 0;
//     });
//     for (var route in routers) {
//       final tempRouteName =
//           (routerName + route.routerName).replaceFirst('//', '/');
//       if (route.child == null) {
//         _masterRouteGuards = route.guards;
//         var _routerName =
//             ('$routerName${route.routerName}/').replaceFirst('//', '/');
//         ModularRouter router;
//         if (_routerName == path || _routerName == "$path/") {
//           final guard = _verifyGuard(route.guards, path);
//           if (guard != null) {
//             return null;
//           }
//           router = route.module.routers[0];
//           if (router.module != null) {
//             var _routerName =
//                 (routerName + route.routerName).replaceFirst('//', '/');
//             router = _searchInModule(route.module, _routerName, path);
//           }
//         } else {
//           router = _searchInModule(route.module, _routerName, path);
//         }

//         if (router != null) {
//           router = router.modulePath == null
//               ? router.copyWith(modulePath: tempRouteName)
//               : router;
//           if (_routerName == path || _routerName == "$path/") {
//             final guard = _verifyGuard(router.guards, path);
//             if (guard != null) {
//               return null;
//             }
//           }

//           if (router.transition == TransitionType.defaultTransition) {
//             router = router.copyWith(
//               transition: route.transition,
//               customTransition: route.customTransition,
//             );
//           }
//           bindModule(route.module, path);
//           return router;
//         }
//       } else {
//         if (searchRoute(route, tempRouteName, path)) {
//           var guards = _prepareGuardList(_masterRouteGuards, route.guards);
//           _masterRouteGuards = null;
//           var guard = _verifyGuard(guards, path);
//           if ((tempRouteName == path || tempRouteName == "$path/") &&
//               path != '/') {
//             guard = _verifyGuard(guards, path);
//           }
//           return guard == null ? route : null;
//         }
//       }
//     }
//     return null;
//   }

//   static List<RouteGuard> _prepareGuardList(
//       List<RouteGuard> moduleGuard, List<RouteGuard> routeGuard) {
//     if (moduleGuard == null) {
//       moduleGuard = [];
//     }
//     if (routeGuard == null) {
//       routeGuard = [];
//     }

//     return List<RouteGuard>.from([...moduleGuard, ...routeGuard]);
//   }

//   @visibleForTesting
//   static ModularRouter selectRoute(String path, [ChildModule module]) {
//     if (path.isEmpty) {
//       throw Exception("Router can not be empty");
//     }
//     final route = _searchInModule(module ?? _initialModule, "", path);
//     return route;
//   }

//   static void oldProccess(Old $old) {
//     if ($old?.args != null) _args = $old?.args?.copy();
//     if ($old?.link != null) _routeLink = $old?.link?.copy();
//   }

//   static Route<T> generateRoute<T>(RouteSettings settings,
//       [ChildModule module, void Function(String) onChangeRoute]) {
//     final isRouterOutlet = module != null;
//     final path = settings.name;
//     var router = selectRoute(path, module);
//     if (router == null) {
//       return null;
//     }
//     if (!isRouterOutlet) {
//       _old = Old(
//         args: args,
//         link: link,
//       );
//       //updateCurrentModule("app");
//     }

//     _args = ModularArguments(router.params, settings.arguments);

//     _routeLink = RouteLink(path: path, modulePath: router.modulePath);

//     if (settings.name == Modular.initialRoute) {
//       router = router.copyWith(transition: TransitionType.noTransition);
//     }

//     if (onChangeRoute != null) {
//       onChangeRoute(path);
//     }

//     return router.getPageRoute(
//         settings: settings,
//         injectMap: _injectMap,
//         isRouterOutlet: isRouterOutlet);
//   }

//   static void addCoreInit(ChildModule module) {
//     var tagText = module.runtimeType.toString();
//     addCoreInitFromTag(module, tagText);
//   }

//   static void addCoreInitFromTag(ChildModule module, String tagText) {
//     module.instance();
//     _injectMap[tagText] = module;
//   }
// }
