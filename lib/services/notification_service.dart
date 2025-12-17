import 'dart:convert';
import 'package:logger/logger.dart';

import 'package:besliyorum_satici/models/notification/notification_model.dart';
import '../core/constants/app_constants.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();

  /// Kullanıcının bildirimlerini getirir
  /// [userToken] - Kullanıcı token'ı
  Future<NotificationResponseModel> getNotifications(String userToken) async {
    try {
      String endpoint = '${Endpoints.notifications}?userToken=$userToken';

      final response = await _apiService.get(endpoint);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return NotificationResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error fetching notifications', error: e);
      rethrow;
    }
  }

  /// Tek bir bildirimi okundu olarak işaretler
  /// [userToken] - Kullanıcı token'ı
  /// [notID] - Bildirim ID'si
  Future<bool> readNotification(String userToken, int notID) async {
    try {
      final response = await _apiService.put(
        Endpoints.notificationRead,
        body: {'userToken': userToken, 'notID': notID},
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['success'] == true;
    } catch (e) {
      _logger.e('Error marking notification as read', error: e);
      rethrow;
    }
  }

  /// Tüm bildirimleri okundu olarak işaretler
  /// [userToken] - Kullanıcı token'ı
  Future<bool> readAllNotifications(String userToken) async {
    try {
      final response = await _apiService.put(
        Endpoints.notificationAllRead,
        body: {'userToken': userToken},
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['success'] == true;
    } catch (e) {
      _logger.e('Error marking all notifications as read', error: e);
      rethrow;
    }
  }
}
