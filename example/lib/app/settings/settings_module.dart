import 'package:flutter_modular/flutter_modular.dart';

import 'package:example/core/state/app_session.dart';
import 'pages/secret_page.dart';
import 'pages/settings_page.dart';
import 'viewmodels/settings_view_model.dart';

/// ---------------------------------------------------------------------------
/// SETTINGS FEATURE — demonstrates route guards + reaching app-scoped state.
///
///  - a GUARD redirects `/settings/secret` until the app is unlocked (it reads
///    the [AppSession] singleton from DI at navigation time);
///  - a page-scoped [SettingsViewModel] flips that same singleton;
///  - the Settings page toggles the APP-SCOPED ThemeController via `read`.
/// ---------------------------------------------------------------------------
final settingsModule = createModule(
  register: (c) {
    c
      ..route(
        '/settings',
        provide: (s) =>
            s.addChangeNotifier<SettingsViewModel>(SettingsViewModel.new),
        child: (ctx, state) => const SettingsPage(),
      )
      ..route(
        '/settings/secret',
        // `inject<T>()` reads DI at guard-eval time without exposing the
        // injector object — Angular-style.
        // A guard redirect is an absolute destination (no context to be
        // relative to), so it names the mounted settings index directly.
        guards: [
          (state) => inject<AppSession>().unlocked ? null : '/home/settings',
        ],
        child: (ctx, state) => const SecretPage(),
      );
  },
);
