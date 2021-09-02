import 'package:flutter/widgets.dart';

class CustomTransition {
  final Widget Function(
          BuildContext, Animation<double>, Animation<double>, Widget)
      transitionBuilder;
  final Duration transitionDuration;

  CustomTransition(
      {required this.transitionBuilder,
      this.transitionDuration = const Duration(milliseconds: 300)});
}
