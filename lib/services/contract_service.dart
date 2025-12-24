import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/auth/contract_model.dart';
import '../models/auth/documents_model.dart';
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

  Future<DocumentsDataModel?> getDocuments(String token) async {
    try {
      debugPrint('📝 [CONTRACT_SERVICE] Dökümanlar getiriliyor...');
      final response = await _apiService.get(
        '${Endpoints.documents}?userToken=$token',
      );
      
      debugPrint('📝 [CONTRACT_SERVICE] Response: ${response.body}');
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final documentsResponse = DocumentsResponseModel.fromJson(responseData);

      if (documentsResponse.success && documentsResponse.data != null) {
        return documentsResponse.data;
      }
      return null;
    } catch (e) {
      debugPrint('❌ [CONTRACT_SERVICE] Dökümanlar yüklenemedi: $e');
      throw Exception('Dökümanlar yüklenemedi: $e');
    }
  }
}
