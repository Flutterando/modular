import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_modular/src/presenter/models/route.dart';
import 'package:flutter_modular/src/presenter/modular_base.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_page.dart';

@immutable
class ModularBook {
  final List<ParallelRoute> routes;
  Uri get uri => routes.isEmpty ? Uri.parse('/') : routes.last.uri;

  ModularBook({required this.routes});

  Iterable<ModularPage> chapters([String chapter = '']) {
    final filteredRoutes = routes.where((route) => route.schema == chapter).toList();
    final pages = <ModularPage>[];
    for (var i = 0; i < filteredRoutes.length; i++) {
      final route = filteredRoutes[i];
      pages.add(ModularPage(
        key: ValueKey('${route.uri.toString()}@$i'),
        route: route,
        args: Modular.args,
        flags: (Modular as ModularBase).flags,
      ));
    }

    return pages;
  }

  ModularBook copyWith({
    List<ParallelRoute>? routes,
    Uri? uri,
  }) {
    return ModularBook(
      routes: routes ?? this.routes,
    );
  }
}
