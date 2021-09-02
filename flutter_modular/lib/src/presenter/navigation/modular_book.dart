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
    return routes.where((route) => route.schema == chapter).map((route) => ModularPage(route: route, args: Modular.args, flags: (Modular as ModularBase).flags));
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
