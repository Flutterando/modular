import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

final tModule = createModule(
  register: (c) {
    c.route(
      '/',
      transition: TransitionType.fade,
      child: (ctx, s) => const Text('faded'),
    );
  },
);

/// A user-supplied transition that owns the whole Page — proving the
/// [PageTransition] contract is open, not limited to the presets.
class _SlidePage extends PageTransition {
  const _SlidePage();

  @override
  Page<void> buildPage(LocalKey key, Widget child) =>
      _Slide(key: key, child: child);
}

class _Slide extends Page<void> {
  const _Slide({required super.key, required this.child});
  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) => PageRouteBuilder<void>(
    settings: this,
    pageBuilder: (_, __, ___) => child,
    transitionsBuilder: (_, animation, __, c) => SlideTransition(
      position: animation.drive(
        Tween(begin: const Offset(1, 0), end: Offset.zero),
      ),
      child: c,
    ),
  );
}

/// The active route hosting [finder]'s element. The material preset yields a
/// route with [MaterialRouteTransitionMixin]; the fade/none presets and any
/// [CustomTransition] yield a [PageRouteBuilder] — a clean way to tell which
/// transition actually drove the page.
ModalRoute<dynamic>? _routeOf(WidgetTester tester, Finder finder) =>
    ModalRoute.of(tester.element(finder));

void main() {
  testWidgets('a route renders with a preset (fade) transition', (
    tester,
  ) async {
    final boot = bootstrapModule(tModule);
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: modularRouterConfig(boot.routes)),
    );
    await tester.pumpAndSettle();

    expect(find.text('faded'), findsOneWidget);
    expect(_routeOf(tester, find.text('faded')), isA<PageRouteBuilder>());
  });

  testWidgets('CustomTransition drives the supplied animation', (tester) async {
    final module = createModule(
      register: (c) {
        c.route(
          '/',
          transition: CustomTransition(
            transitionsBuilder: (context, animation, secondary, child) =>
                SlideTransition(
                  position: animation.drive(
                    Tween(begin: const Offset(1, 0), end: Offset.zero),
                  ),
                  child: child,
                ),
          ),
          child: (ctx, s) => const Text('slid'),
        );
      },
    );
    final boot = bootstrapModule(module);
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: modularRouterConfig(boot.routes)),
    );
    await tester.pumpAndSettle();

    expect(find.text('slid'), findsOneWidget);
    expect(find.byType(SlideTransition), findsWidgets);
    expect(_routeOf(tester, find.text('slid')), isA<PageRouteBuilder>());
  });

  testWidgets('a custom PageTransition implementation owns its Page', (
    tester,
  ) async {
    final module = createModule(
      register: (c) {
        c.route(
          '/',
          transition: const _SlidePage(),
          child: (ctx, s) => const Text('own'),
        );
      },
    );
    final boot = bootstrapModule(module);
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: modularRouterConfig(boot.routes)),
    );
    await tester.pumpAndSettle();

    expect(find.text('own'), findsOneWidget);
    expect(find.byType(SlideTransition), findsWidgets);
  });

  testWidgets('a route with no transition inherits the app-wide default', (
    tester,
  ) async {
    final module = createModule(
      register: (c) {
        c.route('/', child: (ctx, s) => const Text('default'));
      },
    );
    final boot = bootstrapModule(module);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(
          boot.routes,
          defaultTransition: TransitionType.fade,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('default'), findsOneWidget);
    // The global fade applied: a PageRouteBuilder, not the material route.
    expect(_routeOf(tester, find.text('default')), isA<PageRouteBuilder>());
  });

  testWidgets('a local route transition overrides the app-wide default', (
    tester,
  ) async {
    final module = createModule(
      register: (c) {
        c.route(
          '/',
          transition: TransitionType.material,
          child: (ctx, s) => const Text('local'),
        );
      },
    );
    final boot = bootstrapModule(module);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(
          boot.routes,
          defaultTransition: TransitionType.fade,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Local `material` wins over the global `fade`: a material route, not the
    // fade preset's PageRouteBuilder.
    expect(find.text('local'), findsOneWidget);
    final route = _routeOf(tester, find.text('local'));
    expect(route, isA<MaterialRouteTransitionMixin>());
    expect(route, isNot(isA<PageRouteBuilder>()));
  });

  testWidgets('the default-of-default is material', (tester) async {
    final module = createModule(
      register: (c) {
        c.route('/', child: (ctx, s) => const Text('material'));
      },
    );
    final boot = bootstrapModule(module);
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: modularRouterConfig(boot.routes)),
    );
    await tester.pumpAndSettle();

    expect(find.text('material'), findsOneWidget);
    final route = _routeOf(tester, find.text('material'));
    expect(route, isA<MaterialRouteTransitionMixin>());
    expect(route, isNot(isA<PageRouteBuilder>()));
  });
}
