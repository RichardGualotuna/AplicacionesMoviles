import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/crop.dart';

class CropSelector extends StatelessWidget {
  final List<Crop> crops;
  final Function(String) onCropSelected;

  const CropSelector({
    super.key,
    required this.crops,
    required this.onCropSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: crops.length,
      itemBuilder: (context, index) {
        final crop = crops[index];
        return GestureDetector(
          onTap: () => onCropSelected(crop.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: crop.isSelected ? AppColors.primaryGreen : AppColors.backgroundGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: crop.isSelected ? AppColors.primaryGreen : AppColors.borderGray,
                width: crop.isSelected ? 2 : 1,
              ),
              boxShadow: crop.isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  crop.icon,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  crop.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: crop.isSelected ? Colors.white : AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}