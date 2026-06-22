import 'package:flutter/foundation.dart';

import 'package:example/core/state/app_session.dart';

/// Page-scoped: flips the app-wide [AppSession] flag the route guard observes.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._session);

  final AppSession _session;

  bool get unlocked => _session.unlocked;

  void setUnlocked(bool value) {
    _session.unlocked = value;
    notifyListeners();
  }
}
