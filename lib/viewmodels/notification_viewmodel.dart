import 'package:flutter/foundation.dart';
import 'package:besliyorum_satici/models/notification/notification_model.dart';
import '../services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  String _emptyMessage = '';
  String get emptyMessage => _emptyMessage;

  /// Bildirimleri yükler
  Future<void> getNotifications(String userToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _notificationService.getNotifications(userToken);

      if (response.success && response.data != null) {
        _notifications = response.data!.notifications;
        _totalItems = response.data!.totalItems;
        _emptyMessage = response.data!.emptyMessage;
      } else {
        _errorMessage = 'Bildirimler yüklenemedi';
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        _errorMessage = '403_LOGOUT';
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// State'i sıfırlar
  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    _notifications = [];
    _totalItems = 0;
    _emptyMessage = '';
    notifyListeners();
  }

  /// Okunmamış bildirim sayısını döndürür
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Tek bir bildirimi okundu olarak işaretler
  Future<bool> markAsRead(String userToken, int notificationId) async {
    try {
      final success = await _notificationService.readNotification(
        userToken,
        notificationId,
      );

      if (success) {
        // Local state'i güncelle
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Tüm bildirimleri okundu olarak işaretler
  Future<bool> markAllAsRead(String userToken) async {
    try {
      final success = await _notificationService.readAllNotifications(
        userToken,
      );

      if (success) {
        // Local state'i güncelle
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}
