import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeMode mode = ThemeMode.light;
  void toggle() {
    mode = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

final module = createModule(
  register: (c) {
    c.route(
      '/',
      child: (ctx, s) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => ctx.read<ThemeViewModel>().toggle(),
            child: const Text('toggle'),
          ),
        ),
      ),
    );
  },
);

class _Root extends StatelessWidget {
  const _Root();
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeViewModel>();
    return MaterialApp.router(
      themeMode: theme.mode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      routerConfig: ModularApp.routerConfigOf(context),
    );
  }
}

void main() {
  testWidgets(
    'app-scoped VM above the MaterialApp drives the theme (rebuilds it); '
    'a page below reaches it via context.read',
    (tester) async {
      await tester.pumpWidget(
        ModularApp(
          module: module,
          provide: (s) =>
              s.addChangeNotifier<ThemeViewModel>(ThemeViewModel.new),
          child: const _Root(),
        ),
      );
      await tester.pumpAndSettle();

      MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app().themeMode, ThemeMode.light);

      await tester.tap(find.text('toggle'));
      await tester.pumpAndSettle();

      expect(app().themeMode, ThemeMode.dark);
    },
  );
}
