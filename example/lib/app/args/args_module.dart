import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'models/editor_args.dart';
import 'pages/args_home_page.dart';
import 'pages/editor_page.dart';

/// ---------------------------------------------------------------------------
/// ARGS FEATURE — passing an OBJECT and getting a RESULT back.
///
///  - `context.pushNamed('/args/editor', arguments: EditorArgs(...))` passes an
///    arbitrary object, recovered through `RouteState.arguments`;
///  - the editor returns a value via `context.pop(result)`, which completes the
///    `Future` returned by `pushNamed` at the call site.
///
/// Unlike `:id` path params, `arguments` is NOT in the URL — so a deep link to
/// `/args/editor` arrives with `arguments == null`; read it defensively.
/// ---------------------------------------------------------------------------
final argsModule = createModule(
  register: (c) {
    c
      ..route('/args', child: (ctx, state) => const ArgsHomePage())
      ..route(
        '/args/editor',
        child: (ctx, state) {
          final args = state.arguments;
          if (args is! EditorArgs) {
            return const Scaffold(
              body: Center(child: Text('Open this from the Arguments page.')),
            );
          }
          return EditorPage(args: args);
        },
      );
  },
);
