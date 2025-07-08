import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductViewModel extends ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get products => _products;

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(String id, Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Product? getById(String id) {
    return _products.firstWhere((p) => p.id == id, orElse: () => null as Product);
  }
}
