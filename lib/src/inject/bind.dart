import 'package:flutter_modular/flutter_modular.dart';

class Bind<T> {
  final T Function(Inject i) inject;
  final bool singleton;

  Bind(this.inject, {this.singleton = true});
}
