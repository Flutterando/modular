import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

/// Launches `/editor` with an object argument and shows whatever it pops back.
class _Home extends StatefulWidget {
  const _Home();
  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  String? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(result == null ? 'no-result' : 'result:$result'),
          TextButton(
            onPressed: () async {
              final r = await context.pushNamed<String>(
                '/editor',
                arguments: 'payload-42',
              );
              if (!mounted) return;
              setState(() => result = r);
            },
            child: const Text('open'),
          ),
        ],
      ),
    );
  }
}

Widget _editor(BuildContext ctx, RouteState s) => Scaffold(
  body: Column(
    children: [
      Text('arg:${s.arguments}'),
      TextButton(
        onPressed: () => ctx.pop('edited!'),
        child: const Text('save'),
      ),
    ],
  ),
);

final rootArgsModule = createModule(
  register: (c) {
    c
      ..route('/', child: (ctx, s) => const _Home())
      ..route('/editor', child: _editor);
  },
);

/// Same flow, but the launcher/editor live INSIDE a nested outlet.
class _Launcher extends StatefulWidget {
  const _Launcher();
  @override
  State<_Launcher> createState() => _LauncherState();
}

class _LauncherState extends State<_Launcher> {
  String? result;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(result == null ? 'none' : 'got:$result'),
        TextButton(
          onPressed: () async {
            final r = await context.pushNamed<String>(
              '/shell/editor',
              arguments: 'X',
            );
            if (!mounted) return;
            setState(() => result = r);
          },
          child: const Text('go'),
        ),
      ],
    );
  }
}

final shellArgsModule = createModule(
  register: (c) {
    c.route(
      '/shell',
      child: (ctx, s) => const Scaffold(body: RouterOutlet()),
      children: (sub) {
        sub
          ..route('/', child: (ctx, s) => const _Launcher())
          ..route('/editor', child: _editor);
      },
    );
  },
);

void main() {
  testWidgets('arguments reach RouteState; pop result completes pushNamed', (
    tester,
  ) async {
    final boot = bootstrapModule(rootArgsModule);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(boot.routes, injector: boot.injector),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('no-result'), findsOneWidget);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('arg:payload-42'), findsOneWidget); // arg → RouteState

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();
    expect(find.text('result:edited!'), findsOneWidget); // pop result awaited
  });

  testWidgets('arguments + pop result also work through a nested outlet', (
    tester,
  ) async {
    final boot = bootstrapModule(shellArgsModule);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(
          boot.routes,
          injector: boot.injector,
          initialRoute: '/shell',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('none'), findsOneWidget);

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('arg:X'), findsOneWidget);

    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();
    expect(find.text('got:edited!'), findsOneWidget);
  });
}
