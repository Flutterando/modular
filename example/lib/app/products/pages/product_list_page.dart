import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../viewmodels/product_list_view_model.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    // The view drives the VM (params go to the view, not the VM constructor).
    context.read<ProductListViewModel>().load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductListViewModel>();
    return Scaffold(
      appBar: AppBar(
        // `module(at:)` is a namespace now, so this is a normal root page — the
        // automatic back arrow works (no nested outlet swallowing it).
        title: const Text('Products'),
        actions: [
          // `Selector`: this badge rebuilds ONLY when the count changes.
          Selector<ProductListViewModel, int>(
            selector: (_, vm) => vm.products.length,
            builder: (_, count, __) => Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('$count items'),
              ),
            ),
          ),
        ],
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (final p in vm.products)
                  ListTile(
                    title: Text(p.name),
                    subtitle: Text('\$${p.price.toStringAsFixed(2)}'),
                    trailing: const Icon(Icons.chevron_right),
                    // RELATIVE route: we're on `/products`, so a bare `id`
                    // resolves to `/products/$id` (no absolute prefix needed).
                    onTap: () => context.pushNamed(p.id),
                  ),
              ],
            ),
    );
  }
}
