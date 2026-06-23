import 'package:flutter_modular/flutter_modular.dart';

import 'data/realtime_connection.dart';
import 'pages/product_detail_page.dart';
import 'pages/product_list_page.dart';
import 'viewmodels/product_detail_view_model.dart';
import 'viewmodels/product_list_view_model.dart';

/// ---------------------------------------------------------------------------
/// PRODUCTS FEATURE — the module wires the whole feature boundary: its routes
/// and the page-scoped state each route provides. The screens and view models
/// live in `pages/` and `viewmodels/`.
///
/// Demonstrates: page-scoped view models (`addChangeNotifier`), params to the
/// view (`/:id`), `add` (non-reactive `Disposable` resource), and `addStream`.
/// ---------------------------------------------------------------------------

/// `addStream` demo: a live "people viewing" ticker.
Stream<int> _viewersStream() =>
    Stream<int>.periodic(const Duration(seconds: 2), (i) => 40 + i);

/// Declares its own `path` → mounted at `/products` by `module(productsModule)`,
/// so these relative routes become `/products` (list) and `/products/:id`.
final productsModule = createModule(
  path: '/products',
  register: (c) {
    c
      ..route(
        '/',
        provide: (s) {
          s.addChangeNotifier<ProductListViewModel>(ProductListViewModel.new);
        },
        child: (ctx, state) => const ProductListPage(),
      )
      ..route(
        '/:id',
        provide: (s) {
          s
            ..add<RealtimeConnection>(RealtimeConnection.new)
            ..addChangeNotifier<ProductDetailViewModel>(
              ProductDetailViewModel.new,
            )
            ..addStream<int>(_viewersStream);
        },
        child: (ctx, RouteState state) => ProductDetailPage(id: state['id']!),
      );
  },
);
