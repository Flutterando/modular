import 'dart:async';

import 'package:modular_interfaces/modular_interfaces.dart';

import '../../modular_core.dart' show ModularTracker;

class AsyncBind<T extends Object> extends Bind<Future<T>> {
  final Future<T> Function(Injector i) asyncInject;

  ///export bind for others modules
  final bool export;

  AsyncBind(this.asyncInject, {this.export = false}) : super(asyncInject, export: export);

  Future<T> resolveAsyncBind() async {
    final bind = await asyncInject(ModularTracker.injector);
    return bind;
  }

  Future<Bind<T>> converToAsyncBind() async {
    final bindValue = await resolveAsyncBind();
    return Bind<T>((i) => bindValue, export: export);
  }
}
