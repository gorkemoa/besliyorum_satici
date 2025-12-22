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

  /// Siparişi onayla ve işleme al
  /// [userToken] - Kullanıcı token'ı
  /// [orderID] - Sipariş ID'si
  Future<OrderConfirmResponseModel> confirmOrder(
    String userToken,
    int orderID,
  ) async {
    try {
      final body = {
        "userToken": userToken,
        "orderID": orderID,
      };

      final response = await _apiService.post(Endpoints.orderConfirm, body: body);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return OrderConfirmResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error confirming order', error: e);
      rethrow;
    }
  }

  /// Siparişi iptal et
  /// [userToken] - Kullanıcı token'ı
  /// [orderID] - Sipariş ID'si
  /// [cancelProducts] - İptal edilecek ürünler listesi
  Future<OrderCancelResponseModel> cancelOrder(
    String userToken,
    int orderID,
    List<CancelProduct> cancelProducts,
  ) async {
    try {
      final body = {
        "userToken": userToken,
        "orderID": orderID,
        "cancelProducts": cancelProducts.map((e) => e.toJson()).toList(),
      };

      final response = await _apiService.post(Endpoints.orderCancel, body: body);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return OrderCancelResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error canceling order', error: e);
      rethrow;
    }
  }

  /// Sipariş iptal nedenlerini getirir
  Future<OrderCancelTypeResponseModel> getOrderCancelTypes() async {
    try {
      final response = await _apiService.get(Endpoints.orderCancelTypes);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return OrderCancelTypeResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error fetching order cancel types', error: e);
      rethrow;
    }
  }

  /// Kargo etiketi oluştur
  /// [userToken] - Kullanıcı token'ı
  /// [trackingNo] - Takip numarası
  Future<CreateLabelResponseModel> createLabel(
    String userToken,
    String trackingNo,
  ) async {
    try {
      final body = {
        "userToken": userToken,
        "trackingNo": trackingNo,
      };

      final response = await _apiService.post(Endpoints.createLabel, body: body);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return CreateLabelResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error creating label', error: e);
      rethrow;
    }
  }

  /// Kargo ekle (sipariş veya ürün bazında)
  /// [userToken] - Kullanıcı token'ı
  /// [targetID] - Sipariş ID veya Ürün ID (opID)
  /// [step] - 'order' veya 'product'
  /// [trackingNo] - Takip numarası
  Future<AddCargoResponseModel> addOrderCargo(
    String userToken,
    int targetID,
    String step,
    String trackingNo,
  ) async {
    try {
      final body = {
        "userToken": userToken,
        "targetID": targetID,
        "step": step,
        "trackingNo": trackingNo,
      };

      final response = await _apiService.post(Endpoints.addOrderCargo, body: body);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return AddCargoResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error adding cargo', error: e);
      rethrow;
    }
  }
}
