import 'package:flutter/material.dart';
import '../models/notification.dart';

class NotificationsViewModel extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  // Getters
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  
  List<AppNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  
  int get unreadCount => unreadNotifications.length;

  NotificationsViewModel() {
    _loadNotifications();
  }

  void _loadNotifications() {
    _notifications = [
      AppNotification(
        id: '1',
        title: 'Alerta Climática',
        message: 'Se pronostican lluvias intensas para mañana en Cotopaxi. Considera proteger tu cultivo.',
        type: NotificationType.weather,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      AppNotification(
        id: '2',
        title: 'Consejo Semanal',
        message: 'Es el momento ideal para aplicar fertilizante foliar en tu maíz.',
        type: NotificationType.tip,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: '3',
        title: 'Control de Plagas',
        message: 'Monitorea tu cultivo por posible presencia de gusano cogollero.',
        type: NotificationType.pest,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
      ),
      AppNotification(
        id: '4',
        title: 'Recordatorio de Fertilización',
        message: 'Es hora de aplicar la segunda dosis de fertilizante en tu cultivo.',
        type: NotificationType.reminder,
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        isRead: false,
      ),
      AppNotification(
        id: '5',
        title: 'Nueva Guía Disponible',
        message: 'Descarga la nueva guía de manejo integrado de cultivos andinos.',
        type: NotificationType.info,
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        isRead: true,
      ),
    ];
  }

  Future<void> refreshNotifications() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    _loadNotifications();
    _isLoading = false;
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  String getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.weather:
        return '🌧️';
      case NotificationType.tip:
        return '💡';
      case NotificationType.pest:
        return '🐛';
      case NotificationType.reminder:
        return '⏰';
      case NotificationType.info:
        return 'ℹ️';
    }
  }

  Color getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.weather:
        return Colors.blue;
      case NotificationType.tip:
        return Colors.orange;
      case NotificationType.pest:
        return Colors.red;
      case NotificationType.reminder:
        return Colors.green;
      case NotificationType.info:
        return Colors.purple;
    }
  }

  String getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}