import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../product_form/product_form_screen.dart';
import 'widgets/product_card.dart';
import 'widgets/loading_state.dart';
import 'widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Future.microtask waits one tick until widget is fully in the tree
    // context.read = grab provider to CALL a method (not listen to state)
    Future.microtask(() =>
        context.read<ProductProvider>().fetchProducts()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A6B),
        title: const Text(
          'Product Catalog',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Consumer listens to ProductProvider
      // Rebuilds ONLY this body section when notifyListeners() fires
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          // Check states in order: loading → error → empty → data
          if (provider.isLoading) return const LoadingState();
          if (provider.hasError) return _buildError(provider.errorMessage!);
          if (provider.isEmpty) return const EmptyState();
          return _buildProductList(provider.products);
        },
      ),
      // FAB — no product passed = Add mode in ProductFormScreen
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1B2A6B),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProductFormScreen(),
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'ADD PRODUCT',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Builds scrollable list of ProductCards
  Widget _buildProductList(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      // Only builds cards visible on screen — efficient for large lists
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }

  // Shows when API call fails
  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          // Retry button refetches from API
          ElevatedButton(
            onPressed: () =>
                context.read<ProductProvider>().fetchProducts(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}