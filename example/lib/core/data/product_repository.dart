import '../models/product.dart';
import 'product_service.dart';

/// SSoT: the single place product truth lives. Caches the catalog and serves it
/// to any view model that asks. Depends on [ProductService] via DI.
class ProductRepository {
  ProductRepository(this._service);

  final ProductService _service;
  List<Product>? _cache;

  Future<List<Product>> getProducts() async =>
      _cache ??= await _service.fetchAll();

  Future<Product?> getById(String id) async {
    for (final p in await getProducts()) {
      if (p.id == id) return p;
    }
    return null;
  }
}
