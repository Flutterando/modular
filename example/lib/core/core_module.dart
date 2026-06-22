import 'package:flutter_modular/flutter_modular.dart';

import 'data/product_repository.dart';
import 'data/product_service.dart';
import 'state/app_session.dart';

/// ---------------------------------------------------------------------------
/// CORE — the shared DATA LAYER (Flutter "App Architecture").
///
/// A [ProductService] (a remote-ish data source) sits behind a
/// [ProductRepository] that is the SINGLE SOURCE OF TRUTH. View models never
/// hold the truth — they read it from the repository. Everything here is an
/// app-wide singleton in this route-less module, so it is ROOT-OWNED and lives
/// for the whole app (a leaving route never disposes it).
///
/// This is the architecture flutter_modular pushes: DI + page-scoped lifecycle
/// take the weight off "state management" — the truth has one clear home.
/// ---------------------------------------------------------------------------
final coreModule = createModule(
  register: (c) {
    c
      ..addSingleton<ProductService>(ProductService.new)
      ..addSingleton<ProductRepository>(ProductRepository.new)
      ..addSingleton<AppSession>(AppSession.new);
  },
);
