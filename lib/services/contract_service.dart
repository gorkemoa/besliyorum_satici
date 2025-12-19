import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../models/auth/contract_model.dart';
import 'api_service.dart';

class ContractService {
  final ApiService _apiService = ApiService();

  Future<ContractModel?> getSellerPolicy() async {
    try {
      final response = await _apiService.get(Endpoints.sellerPolicy);
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final contractResponse = ContractResponseModel.fromJson(responseData);

      if (contractResponse.success && contractResponse.data != null) {
        return contractResponse.data;
      }
      return null;
    } catch (e) {
      throw Exception('Satıcı sözleşmesi yüklenemedi: $e');
    }
  }

  Future<ContractModel?> getKvkkPolicy() async {
    try {
      final response = await _apiService.get(Endpoints.kvkkPolicy);
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final contractResponse = ContractResponseModel.fromJson(responseData);

      if (contractResponse.success && contractResponse.data != null) {
        return contractResponse.data;
      }
      return null;
    } catch (e) {
      throw Exception('KVKK sözleşmesi yüklenemedi: $e');
    }
  }

  String getIyzicoPolicyUrl() {
    return Endpoints.iyzicoPolicy;
  }
}
