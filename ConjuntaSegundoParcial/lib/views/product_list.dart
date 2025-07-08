import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/product_viewmodel.dart';
import 'product_form.dart';
import 'product_item.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductViewModel>().products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: Colors.teal[700],
        centerTitle: true,
      ),
      body: products.isEmpty
          ? Center(
              child: Text(
                'No hay productos registrados',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) => ProductItem(product: products[index]),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[700],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductForm()),
          );
        },
        child: const Icon(Icons.add, size: 30),
        tooltip: 'Agregar producto',
      ),
    );
  }
}
