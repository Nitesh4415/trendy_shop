import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/order.dart';
import '../cubit/order_cubit/order_cubit.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/cubit/product_cubit.dart';
import 'package:collection/collection.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Orders? _order;
  final Map<int, Product> _productDetailsCache = {}; // Cache product details

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    final orderCubit = context.read<OrderCubit>();
    _order = orderCubit.getOrderById(widget.orderId);

    if (_order != null) {
      for (var productInOrder in _order!.products) {
        if (!_productDetailsCache.containsKey(productInOrder.productId)) {
          try {
            final product = await context
                .read<ProductCubit>()
                .fetchProductDetailsInternal(productInOrder.productId);
            setState(() {
              _productDetailsCache[product.id] = product;
            });
          } catch (e) {
            if (kDebugMode) {
              print(
                'Error fetching product details for ID ${productInOrder.productId}: $e',
              );
            }
            // Handle error, e.g., show a placeholder or error message
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, orderState) {
          // Refresh order if state changes or if it was null initially
          if (_order == null && orderState is OrderHistoryLoaded) {
            _order = orderState.orders.firstWhereOrNull(
              (o) => o.id == widget.orderId,
            );
            if (_order != null) {
              _loadOrderDetails(); // Reload products if order found now
            }
          }

          if (orderState is OrderLoading && _order == null) {
            return const Center(child: CircularProgressIndicator());
          } else if (_order == null) {
            return const Center(child: Text('Order details not found.'));
          }

          double totalAmount = _order!.products.fold(0.0, (sum, p) {
            final product = _productDetailsCache[p.productId];
            return sum + (product != null ? product.price * p.quantity : 0.0);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ID: ${_order!.id ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Order Date: ${_order!.date.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Items:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _order!.products.length,
                  itemBuilder: (context, index) {
                    final productInOrder = _order!.products[index];
                    final product =
                        _productDetailsCache[productInOrder.productId];

                    if (product == null) {
                      return ListTile(
                        title: Text(
                          'Product ID: ${productInOrder.productId} (Loading...)',
                        ),
                        subtitle: Text('Quantity: ${productInOrder.quantity}'),
                        trailing: const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      );
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Image.network(
                              product.image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 30),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text('Quantity: ${productInOrder.quantity}'),
                                  Text(
                                    'Price: \$${product.price.toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${(product.price * productInOrder.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
