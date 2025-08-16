// widgets/behavior_alert_widget.dart
import 'package:flutter/material.dart';
import '../models/behavior_model.dart';
import '../config/constants.dart';

class BehaviorAlertWidget extends StatefulWidget {
  final BehaviorModel behavior;
  final bool autoHide;
  final Duration displayDuration;
  final VoidCallback? onDismiss;

  const BehaviorAlertWidget({
    super.key,
    required this.behavior,
    this.autoHide = true,
    this.displayDuration = const Duration(seconds: 5),
    this.onDismiss,
  });

  @override
  State<BehaviorAlertWidget> createState() => _BehaviorAlertWidgetState();
}

class _BehaviorAlertWidgetState extends State<BehaviorAlertWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    if (widget.autoHide) {
      Future.delayed(widget.displayDuration, () {
        if (mounted) {
          _hide();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _hide() {
    _animationController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForSeverity(widget.behavior.severity);
    final icon = AppConstants.behaviorIcons[
      widget.behavior.type.toString().split('.').last
    ] ?? '⚠️';

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.95),
            child: InkWell(
              onTap: _hide,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getBehaviorTitle(widget.behavior.type),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Confianza: ${(widget.behavior.confidence * 100).toStringAsFixed(0)}% • ${_getSeverityText(widget.behavior.severity)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Close button
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _hide,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForSeverity(SeverityLevel severity) {
    switch (severity) {
      case SeverityLevel.low:
        return Colors.blue;
      case SeverityLevel.medium:
        return Colors.orange;
      case SeverityLevel.high:
        return Colors.deepOrange;
      case SeverityLevel.critical:
        return Colors.red;
    }
  }

  String _getBehaviorTitle(BehaviorType type) {
    switch (type) {
      case BehaviorType.intoxication:
        return 'Intoxicación Detectada';
      case BehaviorType.violence:
        return 'Violencia Detectada';
      case BehaviorType.theft:
        return 'Posible Robo';
      case BehaviorType.fall:
        return 'Caída Detectada';
      case BehaviorType.suspicious:
        return 'Comportamiento Sospechoso';
      case BehaviorType.aggression:
        return 'Agresión Detectada';
      case BehaviorType.normal:
        return 'Comportamiento Normal';
    }
  }

  String _getSeverityText(SeverityLevel severity) {
    switch (severity) {
      case SeverityLevel.low:
        return 'Severidad Baja';
      case SeverityLevel.medium:
        return 'Severidad Media';
      case SeverityLevel.high:
        return 'Severidad Alta';
      case SeverityLevel.critical:
        return 'CRÍTICO';
    }
  }
}