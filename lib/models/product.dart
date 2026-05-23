class Product {
  final String? id;
  final String name;
  final double price;

  Product({
    this.id,
    required this.name,
    required this.price
  });

  factory Product.fromJson(Map<String, dynamic> json){
    return Product(
        id: json["_id"] as String?,
        name: json["name"] as String,
        price: json["price"] as double
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'price': price
      };
}