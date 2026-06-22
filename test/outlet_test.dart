import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

class DashVM extends ChangeNotifier {
  final String title = 'Dashboard';
}

class OverviewVM extends ChangeNotifier {
  final int count = 7;
}

final dashModule = createModule(
  register: (c) {
    c.route(
      '/dashboard',
      provide: (s) => s.addChangeNotifier<DashVM>(DashVM.new),
      child: (ctx, state) => Scaffold(
        body: Column(
          children: [
            Text('shell:${ctx.watch<DashVM>().title}'),
            const Expanded(child: RouterOutlet()),
          ],
        ),
      ),
      children: (sub) {
        sub.route(
          '/overview',
          provide: (s) => s.addChangeNotifier<OverviewVM>(OverviewVM.new),
          child: (ctx, state) {
            final overview = ctx.watch<OverviewVM>();
            final dash = ctx.watch<DashVM>(); // parent VM, through the outlet
            return Text('overview:${overview.count}:${dash.title}');
          },
        );
      },
    );
  },
);

void main() {
  testWidgets(
    'renders nested child in the parent outlet; child sees parent VM',
    (tester) async {
      final boot = bootstrapModule(dashModule);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: modularRouterConfig(
            boot.routes,
            injector: boot.injector,
            initialRoute: '/dashboard/overview',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Parent shell rendered...
      expect(find.text('shell:Dashboard'), findsOneWidget);
      // ...and the child rendered in its outlet, reading BOTH its own VM
      // and the parent's DashVM through the nested scope.
      expect(find.text('overview:7:Dashboard'), findsOneWidget);
    },
  );
}
