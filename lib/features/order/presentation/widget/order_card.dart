import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_trendy/features/order/domain/entities/order.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';
import 'package:shop_trendy/features/product/presentation/cubit/product_cubit.dart';

class OrderCard extends StatefulWidget {
  final Orders order;

  const OrderCard({super.key, required this.order});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  final Map<int, Product> _productDetailsCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final productCubit = context.read<ProductCubit>();
    for (var productInOrder in widget.order.products) {
      if (!_productDetailsCache.containsKey(productInOrder.productId)) {
        try {
          final product = await productCubit.fetchProductDetailsInternal(productInOrder.productId);
          if (mounted) {
            setState(() {
              _productDetailsCache[product.id] = product;
            });
          }
        } catch (e) {
          // Handle error if needed
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    double totalAmount = widget.order.products.fold(0.0, (sum, p) {
      final product = _productDetailsCache[p.productId];
      return sum + (product != null ? product.price * p.quantity : 0.0);
    });

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${widget.order.id}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Date: ${widget.order.date.toLocal().toString().split(' ')[0]}'),
            const Divider(height: 20),
            ...widget.order.products.map((productInOrder) {
              final product = _productDetailsCache[productInOrder.productId];
              if (product == null) return const SizedBox.shrink();
              return InkWell(
                onTap: () => context.go('/products/${product.id}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Image.network(product.image, width: 50, height: 50, fit: BoxFit.contain),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Qty: ${productInOrder.quantity}'),
                          ],
                        ),
                      ),
                      Text('\$${(product.price * productInOrder.quantity).toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              );
            }),
            const Divider(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: \$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
