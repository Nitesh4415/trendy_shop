import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_trendy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shop_trendy/features/product/presentation/cubit/product_cubit.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';
import 'package:shop_trendy/features/cart/presentation/widgets/animated_shopping_cart_button.dart';
import '../widgets/custom_pagination.dart';
import '../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Only fetch if products are not already loaded or if a refresh is needed
    if (context.read<ProductCubit>().state is ProductInitial ||
        (context.read<ProductCubit>().state is ProductLoaded &&
            (context.read<ProductCubit>().state as ProductLoaded)
                .products
                .isEmpty)) {
      context.read<ProductCubit>().fetchAllProducts(isInitialLoad: true);
    }

    _scrollController.addListener(() {
      // Check if we are at the bottom of the scroll view
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !context.read<ProductCubit>().isLoadingMore &&
          context.read<ProductCubit>().hasMoreProducts) {
        context.read<ProductCubit>().fetchAllProducts(isInitialLoad: false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          const AnimatedShoppingCartButton(),
          IconButton(
            icon: const Icon(Icons.history), // custom icon for order history
            onPressed: () {
              context.go('/orders');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().signOut();
            },
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
          if (context.read<AuthCubit>().state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          List<Product> products = [];
          bool isLoadingInitial = false;
          bool isLoadingMore = false;
          bool hasError = false;
          String errorMessage = '';

          if (state is ProductLoading) {
            isLoadingInitial = true;
          } else if (state is ProductLoaded) {
            products = state.products;
          } else if (state is ProductLoadingMore) {
            products = state.products;
            isLoadingMore = true;
          } else if (state is ProductError) {
            hasError = true;
            errorMessage = state.message;
            // If there were previously loaded products, display them with the error
            if (context.read<ProductCubit>().state is ProductLoaded) {
              products = (context.read<ProductCubit>().state as ProductLoaded)
                  .products;
            }
          }

          if (isLoadingInitial && products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (hasError && products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load products: $errorMessage'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductCubit>().fetchAllProducts(
                        isInitialLoad: true,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount:
                      products.length +
                      (isLoadingMore
                          ? 1
                          : 0), // Add 1 for loading indicator at end if loading more
                  itemBuilder: (context, index) {
                    if (index < products.length) {
                      final product = products[index];
                      return ProductCard(product: product);
                    } else {
                      // This is the loading indicator at the bottom for pagination
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              // Custom pagination controls (Load More button)
              // Only show if there are more products and not currently loading more
              if (context.read<ProductCubit>().hasMoreProducts &&
                  !isLoadingMore)
                CustomPaginationControls(
                  onLoadMore: () {
                    context.read<ProductCubit>().fetchAllProducts(
                      isInitialLoad: false,
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
