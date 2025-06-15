import 'package:flutter/material.dart';

class CustomPaginationControls extends StatelessWidget {
  // The callback is now of type Future<void> Function() to support async operations.
  final Future<void> Function() onLoadMore;

  const CustomPaginationControls({super.key, required this.onLoadMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ElevatedButton(
          onPressed: onLoadMore,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: const Text('Load More', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
