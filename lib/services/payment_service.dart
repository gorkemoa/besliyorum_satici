import 'dart:convert';
import 'package:logger/logger.dart';

import 'package:besliyorum_satici/models/payment/payment_model.dart';
import '../core/constants/app_constants.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();

  /// Kullanıcının ödemelerini getirir
  /// [userToken] - Kullanıcı token'ı
  Future<PaymentListResponseModel> getPayments(String userToken) async {
    try {
      String endpoint = '${Endpoints.paymentList}?userToken=$userToken';

      final response = await _apiService.get(endpoint);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return PaymentListResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error fetching payments', error: e);
      rethrow;
    }
  }
}
