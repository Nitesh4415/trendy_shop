import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_trendy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shop_trendy/features/auth/presentation/pages/login_page.dart';
import 'package:shop_trendy/features/auth/presentation/pages/register_page.dart';
import 'package:shop_trendy/features/product/presentation/pages/product_list_page.dart';
import 'package:shop_trendy/features/product/presentation/pages/product_detail_page.dart';
import 'package:shop_trendy/features/cart/presentation/page/cart_page.dart';
import 'package:shop_trendy/features/order/presentation/pages/order_history_page.dart';
import 'package:shop_trendy/features/order/presentation/pages/order_detail_page.dart';

// Defines the application's routing configuration using GoRouter
class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          redirect: (BuildContext context, GoRouterState state) {
            final authState = context.read<AuthCubit>().state;
            return authState.isAuthenticated ? '/products' : '/login';
          },
        ),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductListPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final productId = int.parse(state.pathParameters['id']!);
                return ProductDetailPage(productId: productId);
              },
            ),
          ],
        ),
        GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
        GoRoute(
          path: '/orders', // New route for order history
          builder: (context, state) => const OrderHistoryPage(),
          routes: [
            GoRoute(
              path: ':id', // New route for order details
              builder: (context, state) {
                final orderId = int.parse(state.pathParameters['id']!);
                return OrderDetailPage(orderId: orderId);
              },
            ),
          ],
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final authState = context.read<AuthCubit>().state;
        final bool loggedIn = authState.isAuthenticated;
        final bool loggingIn =
            state.uri.path == '/login' || state.uri.path == '/signup';

        if (loggedIn && loggingIn) {
          return '/products';
        }
        if (!loggedIn && !loggingIn) {
          return '/login';
        }
        return null;
      },
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: ${state.error}')),
      ),
    );
  }
}
