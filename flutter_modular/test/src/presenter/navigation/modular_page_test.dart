import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/src/presenter/errors/errors.dart';
import 'package:flutter_modular/src/presenter/models/modular_args.dart';
import 'package:flutter_modular/src/presenter/models/route.dart';
import 'package:flutter_modular/src/presenter/navigation/modular_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_core/modular_core.dart';

import '../modular_base_test.dart';

class BuildContextMock extends Mock implements BuildContext {}

class AnimationMock<T> extends Mock implements Animation<T> {}

void main() {
  test('ModularPage.empty', () {
    final page = ModularPage.empty();
    expect(page.name, '/');
  });

  test('createRoute throw error child null', () {
    final page = ModularPage.empty();
    expect(() => page.createRoute(BuildContextMock()),
        throwsA(isA<ModularPageException>()));
  });

  test('createRoute default route', () {
    final args = ModularArguments.empty();
    final context = BuildContextMock();
    final route = ParallelRouteMock();
    when(() => route.child).thenReturn((_, __) => Container());
    when(() => route.uri).thenReturn(Uri.parse('/'));
    when(() => route.maintainState).thenReturn(true);
    when(() => route.transition).thenReturn(TransitionType.defaultTransition);
    final page = ModularPage(args: args, flags: ModularFlags(), route: route);
    expect(page.createRoute(context), isA<Route>());
  });

  test('createRoute default route cupertino', () {
    final args = ModularArguments.empty();
    final context = BuildContextMock();
    final route = ParallelRouteMock();
    final widget = Container();
    when(() => route.child).thenReturn((_, __) => widget);
    when(() => route.uri).thenReturn(Uri.parse('/'));
    when(() => route.maintainState).thenReturn(true);

    when(() => route.transition).thenReturn(TransitionType.defaultTransition);
    final page = ModularPage(
        args: args, flags: ModularFlags(isCupertino: true), route: route);
    final routePage = page.createRoute(context);
    expect(routePage, isA<CupertinoPageRoute>());
    expect((routePage as CupertinoPageRoute).builder(context), widget);
  });

  test('createRoute noTransition', () {
    final args = ModularArguments.empty();
    final context = BuildContextMock();
    final route = ParallelRouteMock();
    final widget = Container();
    when(() => route.child).thenReturn((_, __) => widget);
    when(() => route.maintainState).thenReturn(true);

    when(() => route.uri).thenReturn(Uri.parse('/'));
    when(() => route.transition).thenReturn(TransitionType.noTransition);
    final page = ModularPage(args: args, flags: ModularFlags(), route: route);
    final pageRoute = page.createRoute(context);
    expect(pageRoute, isA<NoTransitionMaterialPageRoute>());
    expect(
        (pageRoute as NoTransitionMaterialPageRoute).builder(context), widget);
    expect(pageRoute.transitionDuration, Duration.zero);
    expect(
        pageRoute.buildTransitions(
            context, AnimationMock<double>(), AnimationMock<double>(), widget),
        widget);

    final pageRouteGenerate = page.createRoute(context);
    expect(pageRouteGenerate, isA<Route>());
  });

  test('createRoute custom', () {
    final args = ModularArguments.empty();
    final context = BuildContextMock();
    final route = ParallelRouteMock();
    final widget = Container();
    when(() => route.child).thenReturn((_, __) => widget);
    when(() => route.uri).thenReturn(Uri.parse('/'));
    when(() => route.maintainState).thenReturn(true);

    when(() => route.transition).thenReturn(TransitionType.custom);
    when(() => route.customTransition).thenReturn(
        CustomTransition(transitionBuilder: (_, __, ___, child) => child));

    final page = ModularPage(args: args, flags: ModularFlags(), route: route);
    final pageRoute = page.createRoute(context);
    expect(pageRoute, isA<PageRouteBuilder>());
    expect(
        (pageRoute as PageRouteBuilder).pageBuilder(
            context, AnimationMock<double>(), AnimationMock<double>()),
        widget);
  });

  test('createRoute other transitions', () {
    final args = ModularArguments.empty();
    final context = BuildContextMock();
    final route = ParallelRouteMock();
    final widget = Container();

    final transitionMap = ParallelRoute.empty().transitions;
    final anim = AnimationMock<double>();
    when(() => anim.status).thenReturn(AnimationStatus.completed);
    final keys = transitionMap.keys
        .where((k) => k != TransitionType.custom)
        .where((k) => k != TransitionType.defaultTransition)
        .where((k) => k != TransitionType.noTransition)
        .toList();

    for (var key in keys) {
      when(() => route.transition).thenReturn(key);
      when(() => route.transitions).thenReturn(transitionMap);
      when(() => route.child).thenReturn((_, __) => widget);
      when(() => route.maintainState).thenReturn(true);

      when(() => route.uri).thenReturn(Uri.parse('/'));
      when(() => route.duration).thenReturn(Duration.zero);

      final page = ModularPage(args: args, flags: ModularFlags(), route: route);
      final pageRoute = page.createRoute(context);
      expect(pageRoute, isA<PageRouteBuilder>());

      if (key == TransitionType.fadeIn) {
        expect((pageRoute as PageRouteBuilder).pageBuilder(context, anim, anim),
            widget);
        expect(
            pageRoute.buildTransitions(context, AnimationMock<double>(),
                AnimationMock<double>(), widget),
            isA<FadeTransition>());
      } else {
        expect((pageRoute as PageRouteBuilder).pageBuilder(context, anim, anim),
            widget);
        expect(pageRoute.buildTransitions(context, anim, anim, widget),
            isA<Widget>());
      }

      reset(route);
    }
  });
}
