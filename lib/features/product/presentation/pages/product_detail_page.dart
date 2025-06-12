import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_trendy/features/product/presentation/cubit/product_cubit.dart';
import 'package:shop_trendy/features/product/presentation/widgets/product_carousel.dart';
import 'package:shop_trendy/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shop_trendy/features/cart/domain/entities/cart_item.dart';
import 'package:uuid/uuid.dart'; // For generating UUID for cart item

class ProductDetailPage extends StatefulWidget {
  final int productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().fetchProductDetails(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => context.go('/cart'),
          ),
        ],
      ),
      body: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductDetailLoaded) {
            final product = state.product;
            final relatedProducts = state.relatedProducts
                .where((p) => p.id != product.id)
                .take(4) // Limit related products for display
                .toList();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Hero(
                      tag: 'product-${product.id}', // Hero animation tag
                      child: Image.network(
                        product.image,
                        height: 250,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[700], size: 20),
                      Text(
                        '${product.rating.rate.toStringAsFixed(1)} (${product.rating.count} reviews)',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Generate a unique ID for the cart item
                        const Uuid uuid = Uuid();
                        context.read<CartCubit>().addItemToCart(
                          CartItem(
                            id: uuid.v4(), // Use UUID for unique persistent ID
                            product: product,
                            quantity: 1,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.title} added to cart!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Product Carousel for "Related Items"
                  const Text(
                    'Related Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ProductCarousel(products: relatedProducts),
                ],
              ),
            );
          }
          return const Center(child: Text('Product not found.'));
        },
      ),
    );
  }
}
