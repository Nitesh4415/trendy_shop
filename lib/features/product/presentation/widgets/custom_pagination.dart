import 'package:flutter/material.dart';

class CustomPaginationControls extends StatelessWidget {
  final VoidCallback onLoadMore;

  const CustomPaginationControls({
    super.key,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: onLoadMore,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: const Text(
          'Load More',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}