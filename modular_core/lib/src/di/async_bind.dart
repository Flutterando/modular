import 'dart:async';

import 'package:modular_interfaces/modular_interfaces.dart';

import '../../modular_core.dart' show ModularTracker;

class AsyncBind<T extends Object> extends BindContract<Future<T>> {
  final Future<T> Function(Injector i) asyncInject;

  AsyncBind(this.asyncInject, {bool export = false}) : super(asyncInject, export: export);

  Future<T> resolveAsyncBind() async {
    final bind = await asyncInject(ModularTracker.injector);
    return bind;
  }

  Future<BindContract<T>> converToAsyncBind() async {
    final bindValue = await resolveAsyncBind();
    return _Bind<T>((i) => bindValue, export: export);
  }
}

class _Bind<T extends Object> extends BindContract<T> {
  _Bind(T Function(Injector i) factoryFunction, {bool export = false}) : super(factoryFunction, export: export);
}
