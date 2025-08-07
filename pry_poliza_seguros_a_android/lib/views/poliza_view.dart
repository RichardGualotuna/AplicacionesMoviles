import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/poliza_viewmodel.dart';

class PolizaView extends StatelessWidget {
  final _valorController = TextEditingController();
  final _accidentesController = TextEditingController();
  final _propietarioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PolizaViewModel>(context);

    _valorController.text = vm.valorSeguroAuto.toString();
    _accidentesController.text = vm.accidentes.toString();
    _propietarioController.text = vm.propietario;

    return Scaffold(
      appBar: AppBar(
        title: Text("Crear Póliza", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Aquí puedes agregar navegación a otras vistas
          // por ejemplo Navigator.push...
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Usuario"),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInput("Propietario", _propietarioController, (val) {
              vm.propietario = val;
              vm.notifyListeners();
            }),
            SizedBox(height: 12),
            _buildInput("Valor del seguro", _valorController, (val) {
              vm.valorSeguroAuto = double.tryParse(val) ?? 0;
              vm.notifyListeners();
            }, keyboard: TextInputType.number),
            SizedBox(height: 12),
            Text("Modelo de auto:", style: Theme.of(context).textTheme.titleMedium),
            for (var m in ['A', 'B', 'C'])
              _buildRadio("Modelo $m", m, vm.modeloAuto, (val) {
                vm.modeloAuto = val!;
                vm.notifyListeners();
              }),
            SizedBox(height: 12),
            Text("Edad propietario:", style: Theme.of(context).textTheme.titleMedium),
            for (var e in ['18-23', '23-55', '55+'])
              _buildRadio(_textoEdad(e), e, vm.edadPropietario, (val) {
                vm.edadPropietario = val!;
                vm.notifyListeners();
              }),
            SizedBox(height: 12),
            _buildInput("Número de accidentes", _accidentesController, (val) {
              vm.accidentes = int.tryParse(val) ?? 0;
              vm.notifyListeners();
            }, keyboard: TextInputType.number),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.teal,
                ),
                onPressed: vm.calcularPoliza,
                child: Text("CREAR PÓLIZA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Costo total: \$${vm.costoTotal.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, Function(String) onChanged, {TextInputType? keyboard}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  Widget _buildRadio(String label, String value, String groupValue, Function(String?) onChanged) {
    return RadioListTile(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Colors.teal,
    );
  }

  String _textoEdad(String rango) {
    switch (rango) {
      case '18-23':
        return 'Mayor o igual a 18 y menor a 23';
      case '23-55':
        return 'Mayor o igual a 23 y menor a 55';
      default:
        return 'Mayor o igual a 55';
    }
  }
}