import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/product_viewmodel.dart';
import 'views/product_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Registro de Productos',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const ProductList(),
      ),
    );
  }
}
