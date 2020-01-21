import 'package:flutter_modular/flutter_modular.dart';

class Bind {
  final dynamic Function(Inject i) inject;
  final bool singleton;

  Bind(this.inject, {this.singleton = true});
}
