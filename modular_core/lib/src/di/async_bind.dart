import 'dart:async';

import 'package:modular_interfaces/modular_interfaces.dart';

abstract class AsyncBindContract<T extends Object> implements BindContract<Future<T>> {
  Future<T> Function(Injector i) get asyncInject;

  Future<T> resolveAsyncBind();

  Future<BindContract<T>> convertToAsyncBind();
}
