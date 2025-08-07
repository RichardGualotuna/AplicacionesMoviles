import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/poliza_viewmodel.dart';

class PolizaView extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _propietarioController = TextEditingController();
  final _valorController = TextEditingController();
  final _accidentesController = TextEditingController();
  final _edadController = TextEditingController();
  final _buscarController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<PolizaViewModel>(
      builder: (context, vm, child) {
        // Sincronizar controladores con el ViewModel
        if (_propietarioController.text != vm.propietario) {
          _propietarioController.text = vm.propietario;
        }
        if (_valorController.text != vm.valorSeguroAuto.toString() && 
            vm.valorSeguroAuto > 0) {
          _valorController.text = vm.valorSeguroAuto.toString();
        }
        if (_accidentesController.text != vm.accidentes.toString()) {
          _accidentesController.text = vm.accidentes.toString();
        }
        if (_edadController.text != vm.edadPropietario.toString()) {
          _edadController.text = vm.edadPropietario.toString();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Gestión de Pólizas", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.teal,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  vm.nuevo();
                  _propietarioController.clear();
                  _valorController.clear();
                  _accidentesController.clear();
                  _edadController.clear();
                  _buscarController.clear();
                },
              ),
            ],
          ),
          body: vm.isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sección de búsqueda
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Buscar Póliza Existente",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _buscarController,
                                        decoration: InputDecoration(
                                          labelText: "Nombre del propietario",
                                          prefixIcon: Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        vm.buscarPolizaPorNombre(_buscarController.text);
                                      },
                                      icon: Icon(Icons.search),
                                      label: Text("Buscar"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 20),
                        
                        // Sección de creación de póliza
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Crear Nueva Póliza",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 20),
                                
                                TextFormField(
                                  controller: _propietarioController,
                                  decoration: InputDecoration(
                                    labelText: "Nombre del Propietario",
                                    prefixIcon: Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese el nombre';
                                    }
                                    return null;
                                  },
                                  onChanged: (val) {
                                    vm.propietario = val;
                                  },
                                ),
                                
                                SizedBox(height: 15),
                                
                                TextFormField(
                                  controller: _valorController,
                                  decoration: InputDecoration(
                                    labelText: "Valor del Auto (\$)",
                                    prefixIcon: Icon(Icons.attach_money),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese el valor';
                                    }
                                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                      return 'Ingrese un valor válido';
                                    }
                                    return null;
                                  },
                                  onChanged: (val) {
                                    vm.valorSeguroAuto = double.tryParse(val) ?? 0;
                                  },
                                ),
                                
                                SizedBox(height: 15),
                                
                                Text("Modelo del Auto:", 
                                     style: Theme.of(context).textTheme.titleMedium),
                                Row(
                                  children: ['A', 'B', 'C'].map((modelo) {
                                    return Expanded(
                                      child: RadioListTile<String>(
                                        title: Text('Modelo $modelo'),
                                        value: modelo,
                                        groupValue: vm.modeloAuto,
                                        onChanged: (val) {
                                          vm.modeloAuto = val!;
                                          vm.notifyListeners();
                                        },
                                        activeColor: Colors.teal,
                                      ),
                                    );
                                  }).toList(),
                                ),
                                
                                SizedBox(height: 15),
                                
                                TextFormField(
                                  controller: _edadController,
                                  decoration: InputDecoration(
                                    labelText: "Edad del Propietario",
                                    prefixIcon: Icon(Icons.cake),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese la edad';
                                    }
                                    int? edad = int.tryParse(value);
                                    if (edad == null || edad < 18 || edad >= 80) {
                                      return 'La edad debe estar entre 18 y 79 años';
                                    }
                                    return null;
                                  },
                                  onChanged: (val) {
                                    vm.edadPropietario = int.tryParse(val) ?? 18;
                                  },
                                ),
                                
                                SizedBox(height: 15),
                                
                                TextFormField(
                                  controller: _accidentesController,
                                  decoration: InputDecoration(
                                    labelText: "Número de Accidentes",
                                    prefixIcon: Icon(Icons.warning),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese el número de accidentes';
                                    }
                                    return null;
                                  },
                                  onChanged: (val) {
                                    vm.accidentes = int.tryParse(val) ?? 0;
                                  },
                                ),
                                
                                SizedBox(height: 20),
                                
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 15),
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        await vm.crearPoliza();
                                        if (vm.errorMessage == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Póliza creada exitosamente'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      "CALCULAR Y CREAR PÓLIZA",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Mostrar error si existe
                        if (vm.errorMessage != null)
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    vm.errorMessage!,
                                    style: TextStyle(color: Colors.red.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Mostrar resultado
                        if (vm.costoTotal > 0)
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.teal.shade50, Colors.teal.shade100],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.teal.shade300, width: 2),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.check_circle, 
                                     color: Colors.teal, 
                                     size: 50),
                                SizedBox(height: 10),
                                Text(
                                  "Costo Total del Seguro",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                                Text(
                                  "\$${vm.costoTotal.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade900,
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
      },
    );
  }
}