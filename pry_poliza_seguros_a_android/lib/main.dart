import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/poliza_viewmodel.dart';
import 'views/poliza_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PolizaViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gestión de Pólizas',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: PolizaView(),
      ),
    );
  }
}