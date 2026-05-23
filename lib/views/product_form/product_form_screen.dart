import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';

class ProductFormScreen extends StatefulWidget {
  // null = Add mode, has value = Edit mode
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  // FormKey lets us validate all fields at once
  final _formKey = GlobalKey<FormState>();

  // Controllers hold the text field values
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;

  // Tracks if save is in progress — disables button while saving
  bool _isSaving = false;

  // True if a product was passed in (Edit mode)
  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    // Edit mode: pre-fill with existing values
    // Add mode: start empty
    _nameCtrl = TextEditingController(
      text: widget.product?.name ?? '',
    );
    _priceCtrl = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
  }

  @override
  void dispose() {
    // Always dispose controllers to free memory
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // validate() checks all TextFormField validators
    // returns false if any field fails
    if (!_formKey.currentState!.validate()) return;

    // Disable save button while request is in flight
    setState(() => _isSaving = true);

    // Build Product from form values
    final product = Product(
      // Edit mode: keep existing id | Add mode: null (crudcrud assigns it)
      id: widget.product?.id,
      name: _nameCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
    );

    try {
      if (_isEditing) {
        // Edit mode → PUT request
        await context.read<ProductProvider>().updateProduct(product);
      } else {
        // Add mode → POST request
        await context.read<ProductProvider>().addProduct(product);
      }
      // Check widget is still mounted before using context after await
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      // Re-enable button whether success or failure
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A6B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isEditing ? 'Edit Product' : 'Add Product',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Small label above the card
              Text(
                'CATALOG MANAGEMENT',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isEditing ? 'Modify Product' : 'Define New Product',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2A6B),
                ),
              ),
              const SizedBox(height: 32),

              // White card containing the form fields
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Product Name field
                    const Text(
                      'PRODUCT NAME',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        hintText: 'e.g. Enterprise Cloud Module',
                        filled: true,
                        fillColor: const Color(0xFFF5F6FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      // Validator runs when _formKey.currentState!.validate() is called
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Product name cannot be empty';
                        }
                        return null; // null = valid
                      },
                    ),
                    const SizedBox(height: 24),

                    // Price field
                    const Text(
                      'PRICE',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceCtrl,
                      // Shows decimal keyboard on mobile
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        // $ prefix inside the field
                        prefixText: '\$ ',
                        hintText: '0.00',
                        filled: true,
                        fillColor: const Color(0xFFF5F6FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Price cannot be empty';
                        }
                        // tryParse returns null if not a valid number
                        if (double.tryParse(value.trim()) == null) {
                          return 'Please enter a valid price';
                        }
                        return null; // null = valid
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save button — full width
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // null disables the button, _save enables it
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2A6B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSaving
                        // Show spinner inside button while saving
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          _isEditing ? 'Save Changes' : 'Save Product',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cancel button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF1B2A6B),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}