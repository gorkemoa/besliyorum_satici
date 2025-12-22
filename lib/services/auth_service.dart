import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../core/services/local_storage_service.dart';
import 'package:besliyorum_satici/models/auth/login_model.dart';
import 'package:besliyorum_satici/models/auth/register_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  final LocalStorageService _localStorageService = LocalStorageService();

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _apiService.post(
        Endpoints.login,
        body: request.toJson(),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final loginResponse = LoginResponseModel.fromJson(responseData);

      if (loginResponse.success && loginResponse.data != null) {
        await _localStorageService.saveToken(loginResponse.data!.token);
        await _localStorageService.saveUserId(loginResponse.data!.userID);
      }

      return loginResponse;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _apiService.post(
        Endpoints.register,
        body: request.toJson(),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return RegisterResponseModel.fromJson(responseData);
    } catch (e) {
      throw Exception('Kayıt işlemi başarısız: $e');
    }
  }

  Future<Map<String, dynamic>> checkStoreName(String storeName) async {
    try {
      final response = await _apiService.put(
        Endpoints.storeControl,
        body: {'storeName': storeName},
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Mağaza adı kontrolü başarısız: $e');
    }
  }

  Future<void> logout() async {
    await _localStorageService.clearAll();
  }
}
