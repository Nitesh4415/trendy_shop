import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/order_cubit/order_cubit.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<OrderCubit>().fetchOrderHistory(authState.appUser.id!);
    } else {
      // Handle case where user is not authenticated or appUser ID is null
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to view order history.')),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
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
          } else if (state is OrderHistoryLoaded) {
            if (state.orders.isEmpty) {
              return const Center(child: Text('No past orders found.'));
            }
            return ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Order ID: ${order.id ?? 'N/A'}'),
                    subtitle: Text('Date: ${order.date.toLocal().toString().split(' ')[0]}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      if (order.id != null) {
                        context.go('/orders/${order.id}');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order ID not available.')),
                        );
                      }
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: Text('An unexpected error occurred.'));
        },
      ),
    );
  }
}