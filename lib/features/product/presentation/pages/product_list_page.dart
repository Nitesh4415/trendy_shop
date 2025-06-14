import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_trendy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shop_trendy/features/cart/presentation/widgets/animated_shopping_cart_button.dart';
import 'package:shop_trendy/features/product/presentation/cubit/product_cubit.dart';

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
    final productCubit = context.read<ProductCubit>();
    if (productCubit.currentProducts.isEmpty) {
      productCubit.fetchAllProducts(isInitialLoad: true);
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreProducts() async {
    final productCubit = context.read<ProductCubit>();
    if (productCubit.isLoadingMore || !productCubit.hasMoreProducts) return;

    // --- FIX: Capture the scroll position BEFORE loading new items ---
    // This is the key to scrolling to the next page, not the absolute end.
    final oldMaxScrollExtent = _scrollController.position.maxScrollExtent;

    final newItemsLoaded = await productCubit.fetchAllProducts();

    if (newItemsLoaded && mounted) {
      // Add a short delay to allow the GridView to build the new items.
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          _scrollController.animateTo(
            // Animate to the position that WAS the end of the list.
            // This will reveal the new page of items.
            oldMaxScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _onScroll() {
    // Trigger loading when the user is near the bottom of the list.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          const AnimatedShoppingCartButton(),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.go('/orders'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (context.read<AuthCubit>().state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          final productCubit = context.read<ProductCubit>();
          final products = productCubit.currentProducts;
          final isLoadingMore = productCubit.isLoadingMore;

          if (state is ProductLoading && products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductError && products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load products: ${state.message}'),
                  ElevatedButton(
                    onPressed: () =>
                        productCubit.fetchAllProducts(isInitialLoad: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (products.isEmpty && !isLoadingMore && state is! ProductLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No products found.'),
                  ElevatedButton(
                    onPressed: () =>
                        productCubit.fetchAllProducts(isInitialLoad: true),
                    child: const Text('Reload'),
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
                  itemCount: products.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < products.length) {
                      return ProductCard(product: products[index]);
                    } else {
                      // This is the loading indicator at the bottom.
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              // The "Load More" button is a fallback for users who don't scroll.
              if (productCubit.hasMoreProducts && !isLoadingMore)
                CustomPaginationControls(
                  onLoadMore: _loadMoreProducts,
                ),
            ],
          );
        },
      ),
    );
  }
}
