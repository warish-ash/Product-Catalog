import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading circle
          const CircularProgressIndicator(
            color: Color(0xFF1B2A6B),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading products...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1B2A6B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Synchronizing data',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}