import '../models/product.dart';

/// A fake remote data source (simulated latency).
class ProductService {
  static const _catalog = <Product>[
    Product(
      id: '1',
      name: 'Mechanical Keyboard',
      price: 119.90,
      description: 'Hot-swappable, tactile switches, RGB.',
    ),
    Product(
      id: '2',
      name: 'Ergonomic Mouse',
      price: 59.90,
      description: 'Vertical grip, 6 buttons, silent click.',
    ),
    Product(
      id: '3',
      name: '4K Monitor',
      price: 389.00,
      description: '27", USB-C, 99% sRGB.',
    ),
    Product(
      id: '4',
      name: 'USB-C Hub',
      price: 42.50,
      description: '7-in-1, HDMI + Ethernet + PD.',
    ),
  ];

  Future<List<Product>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _catalog;
  }

  Future<Product?> fetchById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    for (final p in _catalog) {
      if (p.id == id) return p;
    }
    return null;
  }
}
