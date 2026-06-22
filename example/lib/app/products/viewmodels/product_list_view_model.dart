import 'package:flutter/foundation.dart';

import 'package:example/core/data/product_repository.dart';
import 'package:example/core/models/product.dart';

/// Page-scoped: 1:1 with the list view. Reads the repository (SSoT) instead of
/// holding the truth itself.
class ProductListViewModel extends ChangeNotifier {
  ProductListViewModel(this._repo);

  final ProductRepository _repo;

  // Starts loading; notify only AFTER the await (a synchronous notify inside
  // the view's initState-triggered load() would fire during build).
  bool loading = true;
  List<Product> products = const [];

  Future<void> load() async {
    products = await _repo.getProducts();
    loading = false;
    notifyListeners();
  }
}
