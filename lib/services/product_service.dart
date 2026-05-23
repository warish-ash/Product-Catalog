import 'dart:convert'; // jsonDecode, jsonEncode
import 'package:http/http.dart' as http; // HTTP calls
import '../core/constants/api_constants.dart';
import '../models/product.dart';

class ProductService {
  // Single source of truth for the API URL
  final String _endpoint = ApiConstants.productEndpoint;

  // GET /products — fetch all products from crudcrud
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(_endpoint));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  // POST /products — send a new product to crudcrud
  Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      // Tell crudcrud we're sending JSON
      headers: {'Content-Type': 'application/json'},
      // Convert Product object → JSON string for the request body
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201) {
      // crudcrud returns the saved product with its new _id
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create product: ${response.statusCode}');
    }
  }

  // PUT /products/:id — update an existing product
  Future<void> updateProduct(Product product) async {
    final response = await http.put(
      // Include the product id in the URL so crudcrud knows which to update
      Uri.parse('$_endpoint/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    // crudcrud returns 200 with empty body on success
    if (response.statusCode != 200) {
      throw Exception('Failed to update product: ${response.statusCode}');
    }
  }

  // DELETE /products/:id — remove a product from crudcrud
  Future<void> deleteProduct(String id) async {
    final response = await http.delete(
      Uri.parse('$_endpoint/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }
}