import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

final controller = StreamController<int>.broadcast();

final sModule = createModule(
  register: (c) {
    c.route(
      '/',
      provide: (s) => s.addStream<int>(() => controller.stream),
      child: (ctx, state) {
        final value = ctx.watch<StreamValue<int>>().value;
        return Text('v:${value ?? 'none'}', textDirection: TextDirection.ltr);
      },
    );
  },
);

void main() {
  testWidgets('addStream exposes the latest value reactively', (tester) async {
    final boot = bootstrapModule(sModule);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(boot.routes, injector: boot.injector),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('v:none'), findsOneWidget);

    controller.add(42);
    await tester.pumpAndSettle();
    expect(find.text('v:42'), findsOneWidget);
  });
}
