import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_trendy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shop_trendy/features/order/domain/entities/order.dart';
import 'package:shop_trendy/features/order/presentation/cubit/order_cubit/order_cubit.dart';
import 'package:shop_trendy/features/order/presentation/widget/order_card.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final authState = context.read<AuthCubit>().state;
    final orderCubit = context.read<OrderCubit>();

    // --- KEY CHANGE ---
    // Only fetch history if the state is not already loaded.
    // After placing an order, the state will be OrderAllLoaded, so this fetch is skipped.
    if (orderCubit.state is! OrderAllLoaded) {
      if (authState is AuthAuthenticated) {
        context.read<OrderCubit>().fetchOrderHistory(authState.appUser.id!);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please log in to view order history.')),
            );
            context.go('/login');
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Current Order'),
            Tab(text: 'Order History'),
          ],
        ),
      ),
      body: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrderAllLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList([if (state.currentOrder != null) state.currentOrder!], 'No current order placed.'),
                _buildOrderList(state.pastOrders, 'No past orders found.'),
              ],
            );
          }
          return const Center(child: Text('Could not load orders.'));
        },
      ),
    );
  }

  Widget _buildOrderList(List<Orders> orders, String noOrdersMessage) {
    if (orders.isEmpty) {
      return Center(child: Text(noOrdersMessage, style: const TextStyle(fontSize: 16, color: Colors.grey),));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return OrderCard(order: orders[index]);
      },
    );
  }
}
