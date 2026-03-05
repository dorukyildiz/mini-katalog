class Product {
  final int id;
  final String name;
  final String tagline;
  final String description;
  final String price;
  final String image;
  final Map<String, dynamic> specs;

  Product({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.price,
    required this.image,
    required this.specs,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      tagline: json['tagline'],
      description: json['description'],
      price: json['price'],
      image: json['image'],
      specs: Map<String, dynamic>.from(json['specs']),
    );
  }
}