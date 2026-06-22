# Flutter Modular example 

```dart
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// A page-scoped view model (built per page mount, disposed on exit).
class CounterViewModel extends ChangeNotifier {
  int count = 0;

  void increment() {
    count++;
    notifyListeners();
  }
}

/// An APP-scoped view model: it lives ABOVE the `MaterialApp`, so toggling it
/// rebuilds the whole app's theme — something a page-scoped VM (below the
/// `Navigator`) cannot do.
class ThemeViewModel extends ChangeNotifier {
  ThemeMode mode = ThemeMode.light;

  void toggle() {
    mode = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

/// The app module: declares DI + routes. The route provides its view model
/// page-scoped via `provide`.
final appModule = createModule(
  register: (c) {
    c.route(
      '/',
      provide: (s) => s.addChangeNotifier<CounterViewModel>(CounterViewModel.new),
      child: (context, state) => const CounterPage(),
    );
  },
);

void main() {
  runApp(
    ModularApp(
      module: appModule,
      // App-scoped state, anchored above the MaterialApp.
      provide: (Scoped s) =>
          s.addChangeNotifier<ThemeViewModel>(ThemeViewModel.new),
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context
        .watch<ThemeViewModel>(); // reactive, above MaterialApp
    return MaterialApp.router(
      title: 'flutter_modular v7 example',
      themeMode: theme.mode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      routerConfig: ModularApp.routerConfigOf(context),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CounterViewModel>(); // reactive, page-scoped
    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter_modular v7 example'),
        actions: [
          IconButton(
            // The app-scoped VM is reachable from a page below the MaterialApp.
            onPressed: context.read<ThemeViewModel>().toggle,
            icon: const Icon(Icons.brightness_6),
          ),
        ],
      ),
      body: Center(child: Text('count: ${vm.count}')),
      floatingActionButton: FloatingActionButton(
        onPressed: context.read<CounterViewModel>().increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

