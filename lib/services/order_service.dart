import 'dart:convert';
import 'package:logger/logger.dart';

import 'package:besliyorum_satici/models/order/order_model.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();

  /// Kullanıcının siparişlerini getirir
  /// [userToken] - Kullanıcı token'ı
  /// [startDate] - Başlangıç tarihi (dd.MM.yyyy formatında)
  /// [endDate] - Bitiş tarihi (dd.MM.yyyy formatında)
  /// [orderCode] - Sipariş kodu
  /// [orderStatus] - Sipariş durumu (1: Beklemede, 2: İşleme Alındı, 3: Kargoya Verildi, 4: Teslim Edildi, 5: İptal Edildi)
  Future<OrderListResponseModel> getUserOrders(
    String userToken, {
    String? startDate,
    String? endDate,
    String? orderCode,
    int? orderStatus,
  }) async {
    try {
      String endpoint = 'service/user/account/order/list?userToken=$userToken';

      if (startDate != null && startDate.isNotEmpty) {
        endpoint += '&filters[startDate]=$startDate';
      }
      if (endDate != null && endDate.isNotEmpty) {
        endpoint += '&filters[endDate]=$endDate';
      }
      if (orderCode != null && orderCode.isNotEmpty) {
        endpoint += '&filters[orderCode]=$orderCode';
      }
      if (orderStatus != null) {
        endpoint += '&filters[orderStatus]=$orderStatus';
      }

      final response = await _apiService.get(endpoint);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return OrderListResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error fetching user orders', error: e);
      rethrow;
    }
  }
}
