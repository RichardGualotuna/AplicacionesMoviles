import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ProductService {
  static const String _storageKey = 'products';

  Future<List<Product>> getAllProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];

    final List<dynamic> decodedList = jsonDecode(jsonString);
    return decodedList.map((item) => Product.fromJson(item)).toList();
  }

  Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(products.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> addProduct(Product product) async {
    final products = await getAllProducts();
    products.add(product);
    await saveProducts(products);
  }

  Future<void> updateProduct(String id, Product updatedProduct) async {
    final products = await getAllProducts();
    final index = products.indexWhere((p) => p.id == id);
    if (index != -1) {
      products[index] = updatedProduct;
      await saveProducts(products);
    }
  }

  Future<void> deleteProduct(String id) async {
    final products = await getAllProducts();
    products.removeWhere((p) => p.id == id);
    await saveProducts(products);
  }
}
