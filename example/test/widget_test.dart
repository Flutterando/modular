import 'package:example/app/app_module.dart';
import 'package:example/app/checkout/data/checkout_service.dart';
import 'package:example/app/dashboard/dashboard_shell.dart';
import 'package:example/core/state/theme_controller.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app() => ModularApp(
  module: appModule,
  initialRoute: '/home', // the landing feature is mounted at /home
  provide: (s) => s.addChangeNotifier<ThemeController>(ThemeController.new),
  child: const AppRoot(),
);

void main() {
  testWidgets('home → products list loads from the repository (SSoT)', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('A tiny store, modular.'), findsOneWidget);

    await tester.tap(find.text('Browse products'));
    await tester.pumpAndSettle();

    // Served by ProductRepository (the single source of truth).
    expect(find.text('Mechanical Keyboard'), findsOneWidget);
    expect(find.text('4 items'), findsOneWidget); // Selector badge

    // The mounted-module index gets an explicit back button (canPop bubbles to
    // the root); tapping it returns home.
    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('A tiny store, modular.'), findsOneWidget);
  });

  testWidgets('settings toggles the app-scoped theme (rebuilds MaterialApp)', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    MaterialApp materialApp() =>
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp().themeMode, ThemeMode.light);

    await tester.tap(find.text('Dark theme'));
    await tester.pumpAndSettle();

    expect(materialApp().themeMode, ThemeMode.dark);
  });

  testWidgets('args flow: pass an object, edit, and pop a result back', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Arguments & pop result'));
    await tester.pumpAndSettle();
    expect(find.text('No result yet — open the editor.'), findsOneWidget);

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    // The object argument arrived: title + prefilled text come from EditorArgs.
    expect(find.text('Edit greeting'), findsOneWidget);
    expect(find.text('Hello, Modular!'), findsOneWidget);

    // Edit and Save → the value is popped back to the awaiting pushNamed.
    await tester.enterText(find.byType(TextField), 'Edited!');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Editor returned: "Edited!"'), findsOneWidget);
  });

  testWidgets(
    'checkout feature module: service bound on enter, kept across its routes, '
    'disposed only after the last leaves, recreated on re-entry',
    (tester) async {
      CheckoutService.opens = 0;
      CheckoutService.closes = 0;

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(CheckoutService.opens, 0); // not entered yet → not bound

      // Enter checkout (route A) → the feature service is created once.
      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Checkout session #'), findsOneWidget);
      expect(CheckoutService.opens, 1);
      expect(CheckoutService.closes, 0);

      // Push the payment route (B) → SAME instance (module still active).
      await tester.tap(find.text('To payment'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Paying for session #'), findsOneWidget);
      expect(CheckoutService.opens, 1);

      // Pop B → A still active → not disposed.
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(CheckoutService.closes, 0);

      // Leave checkout entirely (last route) → disposed.
      await tester.tap(find.text('Back home'));
      await tester.pumpAndSettle();
      expect(CheckoutService.closes, 1);

      // Re-enter → a fresh service instance.
      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();
      expect(CheckoutService.opens, 2);
    },
  );

  testWidgets('dashboard: the RouterOutlet shell persists while the body swaps', (
    tester,
  ) async {
    DashboardShell.inits = 0;
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dashboard (RouterOutlet)'));
    await tester.pumpAndSettle();
    expect(find.text('Feed view'), findsOneWidget); // index tab
    expect(DashboardShell.inits, 1);

    // Switch tabs via the bottom bar → the body swaps, the shell stays mounted.
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Search view'), findsOneWidget);
    expect(find.text('Feed view'), findsNothing);
    expect(DashboardShell.inits, 1); // shell NOT rebuilt → it persisted

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Profile view'), findsOneWidget);
    expect(DashboardShell.inits, 1);

    // Push from inside a tab → stacks INSIDE the outlet, shell still mounted.
    await tester.tap(find.text('Feed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open an item'));
    await tester.pumpAndSettle();
    expect(find.text('Item detail — still inside the shell'), findsOneWidget);
    expect(
      find.byType(NavigationBar),
      findsOneWidget,
    ); // bottom bar still there
    expect(DashboardShell.inits, 1);
  });

  testWidgets('deep link to /home/dashboard boots into the shell (Feed tab)', (
    tester,
  ) async {
    // The platform hands the real entry URL via defaultRouteName — a refresh
    // on the dashboard must land in the shell, not collapse to the landing.
    tester.platformDispatcher.defaultRouteNameTestValue = '/home/dashboard';
    addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Feed view'), findsOneWidget); // seeded inside the outlet
    expect(find.byType(NavigationBar), findsOneWidget); // shell mounted
    expect(find.text('A tiny store, modular.'), findsNothing); // not home
  });

  testWidgets('dashboard: the active-tab highlight is DERIVED from the route '
      '(deep link to a non-default tab, then bottom-bar switches)', (
    tester,
  ) async {
    // Boot straight to the Profile tab — the highlight must follow the route,
    // not collapse to Feed (the dessynced-_index bug this fix closes).
    tester.platformDispatcher.defaultRouteNameTestValue =
        '/home/dashboard/profile';
    addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    NavigationBar bar() =>
        tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(find.text('Profile view'), findsOneWidget);
    expect(bar().selectedIndex, 2); // Profile lit on deep link

    // Switch via the bottom bar → the highlight follows, no local state.
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Search view'), findsOneWidget);
    expect(bar().selectedIndex, 1);

    await tester.tap(find.text('Feed'));
    await tester.pumpAndSettle();
    expect(find.text('Feed view'), findsOneWidget);
    expect(bar().selectedIndex, 0);
  });

  testWidgets('guard redirects the secret route until the app is unlocked', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Locked: the guard redirects back to /settings.
    await tester.tap(find.text('Open secret area'));
    await tester.pumpAndSettle();
    expect(find.text('🔓 Secret area unlocked'), findsNothing);
    expect(find.text('Settings'), findsOneWidget);

    // Unlock, then it is allowed.
    await tester.tap(find.text('Unlock secret area'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open secret area'));
    await tester.pumpAndSettle();
    expect(find.text('🔓 Secret area unlocked'), findsOneWidget);
  });
}
