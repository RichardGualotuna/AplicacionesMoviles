import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../viewmodels/product_viewmodel.dart';
import '../utils/image_helper.dart';
import 'package:uuid/uuid.dart';

class ProductForm extends StatefulWidget {
  final Product? product;

  const ProductForm({Key? key, this.product}) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  double _price = 0.0;
  File? _image;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _name = widget.product!.name;
      _description = widget.product!.description;
      _price = widget.product!.price;
      _image = widget.product!.image;
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newProduct = Product(
        id: widget.product?.id ?? const Uuid().v4(),
        name: _name,
        description: _description,
        price: _price,
        image: _image,
      );

      final viewModel = Provider.of<ProductViewModel>(context, listen: false);
      if (widget.product == null) {
        viewModel.addProduct(newProduct);
      } else {
        viewModel.updateProduct(widget.product!.id, newProduct);
      }

      Navigator.pop(context);
    }
  }

  Future<void> _takePhoto() async {
    final pickedImage = await ImageHelper.pickImageFromCamera();
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Nuevo Producto' : 'Editar Producto'),
        backgroundColor: Colors.teal[700],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _takePhoto,
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover),
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.teal[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt, size: 60, color: Colors.white70),
                            SizedBox(height: 10),
                            Text('Toca para tomar foto', style: TextStyle(color: Colors.white70, fontSize: 16)),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onSaved: (value) => _name = value!,
                validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onSaved: (value) => _description = value ?? '',
                maxLines: 3,
              ),
              const SizedBox(height: 15),
              TextFormField(
                initialValue: _price != 0.0 ? _price.toString() : '',
                decoration: InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) => _price = double.tryParse(value ?? '0') ?? 0,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un precio';
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) return 'Ingrese un precio válido';
                  return null;
                },
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    widget.product == null ? 'Guardar Producto' : 'Actualizar Producto',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
