import 'dart:async';

import 'package:modular_interfaces/modular_interfaces.dart';

/// AsyncBind represents an asynchronous Bind that can be resolved before module initialization by calling Modular.isModuleReady() or called with Modular.getAsync()
abstract class AsyncBindContract<T extends Object>
    implements BindContract<Future<T>> {
  Future<T> Function(Injector i) get asyncInject;

  /// Get the value of the bind
  Future<T> resolveAsyncBind();

  /// Convert to synchronous Bind
  Future<BindContract<T>> convertToBind();
}
