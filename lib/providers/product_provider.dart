import 'package:flutter/foundation.dart'; // ChangeNotifier
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  // Service handles all HTTP calls — provider never touches http directly
  final ProductService _service = ProductService();

  // Private state — UI never accesses these directly
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage; // null means no error

  // Public getters — UI reads these, never the private fields
  // unmodifiable = UI can read but cannot add/remove directly
  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  // isEmpty = finished loading AND no products found
  bool get isEmpty => !_isLoading && _products.isEmpty;

  // Fetch all products from API on app start
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // → UI shows loading spinner immediately

    try {
      _products = await _service.fetchProducts();
    } catch (e) {
      // Store error message so UI can display it
      _errorMessage = e.toString();
    } finally {
      // finally runs whether success OR failure — always stop loading
      _isLoading = false;
      notifyListeners(); // → UI rebuilds with data OR error
    }
  }

  // Add a new product — POST
  Future<void> addProduct(Product product) async {
    try {
      // Use returned product because crudcrud assigns the real _id
      final newProduct = await _service.createProduct(product);
      _products.add(newProduct);
      notifyListeners(); // → UI rebuilds with new product in list
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Update existing product — PUT
  Future<void> updateProduct(Product product) async {
    try {
      await _service.updateProduct(product);
      // Find the product's position in local list by id
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        // Replace old product with updated one at same position
        _products[index] = product;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Delete product by id — DELETE
  Future<void> deleteProduct(String id) async {
    try {
      await _service.deleteProduct(id);
      // Remove from local list — no need to refetch everything
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}