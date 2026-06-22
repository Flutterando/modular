import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

int disposeCalls = 0;

class FakeRepo {
  String widgetName() => 'Widget X';
}

class ProductVM extends ChangeNotifier {
  ProductVM(this._repo);

  final FakeRepo _repo;
  String? name;

  void load() {
    name = _repo.widgetName();
    notifyListeners();
  }

  @override
  void dispose() {
    disposeCalls++;
    super.dispose();
  }
}

final pModule = createModule(
  register: (c) {
    c
      ..addSingleton<FakeRepo>(FakeRepo.new)
      ..route(
        '/product',
        provide: (s) => s.addChangeNotifier<ProductVM>(ProductVM.new),
        child: (ctx, state) {
          final vm = ctx.watch<ProductVM>();
          return Scaffold(
            body: Column(
              children: [
                Text(vm.name ?? 'idle'),
                TextButton(
                  onPressed: () => ctx.read<ProductVM>().load(),
                  child: const Text('load'),
                ),
              ],
            ),
          );
        },
      );
  },
);

void main() {
  setUp(() => disposeCalls = 0);

  testWidgets('builds the VM with module deps; watch rebuilds on notify', (
    tester,
  ) async {
    final boot = bootstrapModule(pModule);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(
          boot.routes,
          injector: boot.injector,
          initialRoute: '/product',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('idle'), findsOneWidget);

    await tester.tap(find.text('load'));
    await tester.pumpAndSettle();

    // 'Widget X' proves the dep (FakeRepo) was resolved from the module
    // injector AND that watch rebuilt on notifyListeners.
    expect(find.text('Widget X'), findsOneWidget);
  });

  testWidgets('disposes the page-scoped VM on unmount', (tester) async {
    final boot = bootstrapModule(pModule);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: modularRouterConfig(
          boot.routes,
          injector: boot.injector,
          initialRoute: '/product',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(disposeCalls, 0);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(disposeCalls, 1);
  });
}
