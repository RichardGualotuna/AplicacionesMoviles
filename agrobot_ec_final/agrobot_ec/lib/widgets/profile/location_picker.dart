import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LocationPicker extends StatelessWidget {
  final String currentLocation;
  final double latitude;
  final double longitude;
  final int altitude;
  final Function(String, double, double, int) onLocationChanged;

  const LocationPicker({
    super.key,
    required this.currentLocation,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Map placeholder
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.backgroundGray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Stack(
            children: [
              // Map background pattern
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.1),
                      AppColors.secondaryGreen.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
              
              // Location info
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 32,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentLocation,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Edit button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit_location,
                      size: 16,
                      color: AppColors.primaryGreen,
                    ),
                    onPressed: () => _showLocationDialog(context),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Location details
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.terrain,
                size: 16,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Zona agroecológica: Región Andina - Clima templado frío',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Altitude info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.height,
                size: 16,
                color: AppColors.infoBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Altitud: $altitude msnm',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar ubicación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selecciona tu ubicación para recibir recomendaciones más precisas:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            
            // Province selector
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Provincia',
                border: OutlineInputBorder(),
              ),
              items: _provinces.map((province) {
                return DropdownMenuItem(
                  value: province,
                  child: Text(province),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final coords = _getProvinceCoordinates(value);
                  onLocationChanged(
                    value,
                    coords['lat']!,
                    coords['lng']!,
                    coords['alt']!.toInt(),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 15),
            
            // GPS button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _getCurrentLocation(context),
                icon: const Icon(Icons.my_location),
                label: const Text('Usar ubicación actual'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _getCurrentLocation(BuildContext context) async {
    // TODO: Implement GPS location
    // For now, simulate getting current location
    await Future.delayed(const Duration(seconds: 1));
    
    onLocationChanged(
      'Ubicación actual',
      -0.9324,
      -78.6156,
      2800,
    );
    
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📍 Ubicación actualizada'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  List<String> get _provinces => [
    'Azuay',
    'Bolívar',
    'Cañar',
    'Carchi',
    'Chimborazo',
    'Cotopaxi',
    'El Oro',
    'Esmeraldas',
    'Galápagos',
    'Guayas',
    'Imbabura',
    'Loja',
    'Los Ríos',
    'Manabí',
    'Morona Santiago',
    'Napo',
    'Orellana',
    'Pastaza',
    'Pichincha',
    'Santa Elena',
    'Santo Domingo de los Tsáchilas',
    'Sucumbíos',
    'Tungurahua',
    'Zamora Chinchipe',
  ];

  Map<String, double> _getProvinceCoordinates(String province) {
    // Simplified coordinates for Ecuadorian provinces
    final coordinates = {
      'Cotopaxi': {'lat': -0.9324, 'lng': -78.6156, 'alt': 2800.0},
      'Pichincha': {'lat': -0.1807, 'lng': -78.4678, 'alt': 2850.0},
      'Chimborazo': {'lat': -1.4676, 'lng': -78.6497, 'alt': 2754.0},
      'Imbabura': {'lat': 0.3717, 'lng': -78.1309, 'alt': 2225.0},
      'Tungurahua': {'lat': -1.2481, 'lng': -78.6267, 'alt': 2577.0},
      'Azuay': {'lat': -2.9001, 'lng': -79.0059, 'alt': 2550.0},
      'Carchi': {'lat': 0.8115, 'lng': -77.7298, 'alt': 2980.0},
      'Bolívar': {'lat': -1.5942, 'lng': -79.0078, 'alt': 2380.0},
      'Cañar': {'lat': -2.5597, 'lng': -78.9404, 'alt': 3100.0},
      'Loja': {'lat': -3.9931, 'lng': -79.2042, 'alt': 2060.0},
    };
    
    return coordinates[province] ?? {'lat': -0.9324, 'lng': -78.6156, 'alt': 2800.0};
  }
}