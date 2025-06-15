import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_trendy/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shop_trendy/features/cart/domain/entities/cart_item.dart';
import 'package:shop_trendy/features/order/domain/entities/order.dart'
    as app_order; // Alias for Order entity
import 'package:shop_trendy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shop_trendy/features/order/domain/entities/product_order.dart';
import 'package:shop_trendy/features/order/presentation/cubit/order_cubit/order_cubit.dart'; // Import AuthCubit to get appUser ID

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is CartPaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment successful! Order placed.'),
              ),
            );
            // The OrderCubit state is already updated, so we just navigate.
            context.go('/orders'); // Navigate to order list after success
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text('Your cart is empty.'));
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Image.network(
                                item.product.image,
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 40),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '\$${item.product.price.toStringAsFixed(2)}',
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                          ),
                                          onPressed: () {
                                            context
                                                .read<CartCubit>()
                                                .decrementQuantity(item.id);
                                          },
                                        ),
                                        Text('${item.quantity}'),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                          ),
                                          onPressed: () {
                                            context
                                                .read<CartCubit>()
                                                .incrementQuantity(item.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  context.read<CartCubit>().removeItemFromCart(
                                    item.id,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${context.read<CartCubit>().cartTotalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Call the private method to handle checkout process
                            _handleCheckout(context, state.items);
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('An unexpected error occurred.'));
        },
      ),
    );
  }

  Future<void> _handleCheckout(
    BuildContext context,
    List<CartItem> cartItems,
  ) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.appUser.id; // Get the user ID

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not available for placing order.'),
          ),
        );
        return;
      }

      final productsInOrder = cartItems
          .map(
            (cartItem) => ProductInOrder(
              productId: cartItem.product.id,
              quantity: cartItem.quantity,
            ),
          )
          .toList();

      final newOrder = app_order.Orders(
        userId: userId,
        date: DateTime.now(),
        products: productsInOrder,
      );

      final orderCubit = context.read<OrderCubit>();
      final cartCubit = context.read<CartCubit>();

      try {
        // Step 1: Create the order in your backend. This updates the OrderCubit state.
        await orderCubit.createOrder(newOrder);

        // Step 2: If order creation was successful, proceed to payment.
        if (orderCubit.state is OrderAllLoaded) {
          await cartCubit.initiatePayment(
            cartCubit.cartTotalPrice,
            'usd', // Assuming USD as currency
          );
          // The listener for CartPaymentSuccess will handle navigation.
        } else if (orderCubit.state is OrderError) {
          final errorMessage = (orderCubit.state as OrderError).message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create order: $errorMessage')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to proceed with checkout.'),
        ),
      );
      context.go('/login');
    }
  }
}
