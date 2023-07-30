import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_triple/flutter_triple.dart';

BindConfig<T> storeConfig<T extends Store>() {
  return BindConfig<T>(
    onDispose: (value) => value.destroy(),
    notifier: (value) => Listenable.merge(
        [value.selectError, value.selectLoading, value.selectState]),
  );
}
