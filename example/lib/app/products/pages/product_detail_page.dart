import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../viewmodels/product_detail_view_model.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({required this.id, super.key});

  final String id;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductDetailViewModel>().load(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductDetailViewModel>();
    final viewers = context.watch<StreamValue<int>>().value; // addStream value
    final product = vm.product;

    return Scaffold(
      appBar: AppBar(title: Text(product?.name ?? 'Loading…')),
      body: vm.loading || product == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: vm.connected ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(vm.connected ? 'connected' : 'offline'),
                      const Spacer(),
                      Text('👀 ${viewers ?? '—'} viewing'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(product.description),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
    );
  }
}
