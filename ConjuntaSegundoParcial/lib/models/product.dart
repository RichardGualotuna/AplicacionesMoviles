import 'dart:io';

class Product {
  String id;
  String name;
  String description;
  double price;
  File? image;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'imagePath': image?.path,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    price: (json['price'] as num).toDouble(),
    image: json['imagePath'] != null ? File(json['imagePath']) : null,
  );
}