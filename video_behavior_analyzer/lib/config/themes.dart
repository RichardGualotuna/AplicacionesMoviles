// config/themes.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppThemes {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3),
      brightness: Brightness.light,
    ),
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF212121),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        color: Color(0xFF212121),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(
        color: Color(0xFF212121),
      ),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      shape: CircleBorder(),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      elevation: 0,
      pressElevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Dialog Theme
    dialogTheme: DialogTheme(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1),
      ),
    ),
    
    // Slider Theme
    sliderTheme: const SliderThemeData(
      activeTrackColor: Color(0xFF2196F3),
      inactiveTrackColor: Color(0xFFE0E0E0),
      thumbColor: Color(0xFF2196F3),
      overlayColor: Color(0x292196F3),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3),
      brightness: Brightness.dark,
    ),
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      elevation: 4,
      shadowColor: Colors.black45,
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF2196F3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      backgroundColor: Color(0xFF2196F3),
      foregroundColor: Colors.white,
      shape: CircleBorder(),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      elevation: 0,
      pressElevation: 2,
      backgroundColor: const Color(0xFF2A2A2A),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Dialog Theme
    dialogTheme: DialogTheme(
      elevation: 8,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 8,
      backgroundColor: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1),
      ),
    ),
    
    // Slider Theme
    sliderTheme: const SliderThemeData(
      activeTrackColor: Color(0xFF2196F3),
      inactiveTrackColor: Color(0xFF424242),
      thumbColor: Color(0xFF2196F3),
      overlayColor: Color(0x292196F3),
    ),
  );
}

// Custom Colors class (separate from AppThemes)
class CustomColors {
  // Status Colors
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF66BB6A);
  static const Color warningLight = Color(0xFFFFC107);
  static const Color warningDark = Color(0xFFFFD54F);
  static const Color errorLight = Color(0xFFFF5252);
  static const Color errorDark = Color(0xFFFF6E6E);
  static const Color infoLight = Color(0xFF2196F3);
  static const Color infoDark = Color(0xFF42A5F5);

  // Gradient Colors
  static const List<Color> primaryGradientLight = [
    Color(0xFF2196F3),
    Color(0xFF00BCD4),
  ];
  
  static const List<Color> primaryGradientDark = [
    Color(0xFF1976D2),
    Color(0xFF0097A7),
  ];
  
  static const List<Color> dangerGradient = [
    Color(0xFFFF5252),
    Color(0xFFFF1744),
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF2E7D32),
  ];

  // Behavior Alert Colors
  static const Map<String, Color> behaviorColors = {
    'intoxication': Color(0xFFFF9800),
    'violence': Color(0xFFFF5252),
    'theft': Color(0xFFE91E63),
    'fall': Color(0xFF9C27B0),
    'suspicious': Color(0xFFFFC107),
    'aggression': Color(0xFFFF5722),
    'normal': Color(0xFF4CAF50),
  };
}

// Custom Text Styles class (separate from AppThemes)
class CustomTextStyles {
  // Headers
  static const TextStyle headerLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headerMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );
  
  static const TextStyle headerSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );
}

// Theme Extension for custom properties
@immutable
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color? successColor;
  final Color? warningColor;
  final Color? dangerColor;
  final Color? infoColor;

  const CustomThemeExtension({
    this.successColor,
    this.warningColor,
    this.dangerColor,
    this.infoColor,
  });

  @override
  CustomThemeExtension copyWith({
    Color? successColor,
    Color? warningColor,
    Color? dangerColor,
    Color? infoColor,
  }) {
    return CustomThemeExtension(
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      dangerColor: dangerColor ?? this.dangerColor,
      infoColor: infoColor ?? this.infoColor,
    );
  }

  @override
  CustomThemeExtension lerp(ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    
    return CustomThemeExtension(
      successColor: Color.lerp(successColor, other.successColor, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      dangerColor: Color.lerp(dangerColor, other.dangerColor, t),
      infoColor: Color.lerp(infoColor, other.infoColor, t),
    );
  }
}