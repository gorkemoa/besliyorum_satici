import 'dart:convert';
import 'package:logger/logger.dart';

import 'package:besliyorum_satici/models/order/order_model.dart';
import 'package:besliyorum_satici/models/order/order_detail_model.dart';
import 'package:besliyorum_satici/models/order/order_status_model.dart';
import '../core/constants/app_constants.dart';
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
      String endpoint = '${Endpoints.orderList}?userToken=$userToken';

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

  /// Sipariş detayını getirir
  /// [userToken] - Kullanıcı token'ı
  /// [orderID] - Sipariş ID'si
  Future<OrderDetailResponseModel> getOrderDetail(
    String userToken,
    int orderID,
  ) async {
    try {
      String endpoint =
          '${Endpoints.orderDetail}?userToken=$userToken&orderID=$orderID';

      final response = await _apiService.get(endpoint);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return OrderDetailResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error fetching order detail', error: e);
      rethrow;
    }
  }

  /// Sipariş durumlarını getirir
  Future<OrderStatusResponseModel> getOrderStatuses() async {
    try {
      final response = await _apiService.get(Endpoints.orderStatuses);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return OrderStatusResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error fetching order statuses', error: e);
      rethrow;
    }
  }
}
