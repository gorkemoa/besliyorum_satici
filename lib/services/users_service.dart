import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:besliyorum_satici/models/home/home_model.dart';
import 'package:besliyorum_satici/models/auth/update_user_model.dart';
import 'package:besliyorum_satici/models/auth/update_password_model.dart';
import '../core/constants/app_constants.dart';
import 'api_service.dart';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

class UsersService {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();

  Future<HomeResponseModel> getUserAccount(int userId, String userToken) async {
    try {
      final String endpoint = 'service/user/account/id/$userId';

      final packageInfo = await PackageInfo.fromPlatform();
      final String version = packageInfo.version;
      final String platform = Platform.isAndroid ? 'android' : 'ios';

      final body = {
        "userToken": userToken,
        "platform": platform,
        "version": version,
      };

      final response = await _apiService.put(endpoint, body: body);

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return HomeResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error fetching user account', error: e);
      rethrow;
    }
  }

  Future<UpdateUserResponseModel> updateUser(UpdateUserRequestModel request) async {
    try {
      final response = await _apiService.put(
        Endpoints.updateUser,
        body: request.toJson(),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return UpdateUserResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error updating user', error: e);
      rethrow;
    }
  }

  Future<UpdatePasswordResponseModel> updatePassword(UpdatePasswordRequestModel request) async {
    try {
      debugPrint('🔐 [USERS_SERVICE] Şifre değiştirme isteği gönderiliyor: ${Endpoints.updatePassword}');
      debugPrint('🔐 [USERS_SERVICE] Request Body: ${request.toJson()}');
      
      final response = await _apiService.put(
        Endpoints.updatePassword,
        body: request.toJson(),
      );

      debugPrint('🔐 [USERS_SERVICE] Response Status: ${response.statusCode}');
      debugPrint('🔐 [USERS_SERVICE] Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return UpdatePasswordResponseModel.fromJson(responseData);
    } catch (e) {
      debugPrint('🔐 [USERS_SERVICE] HATA: $e');
      _logger.d('Error updating password', error: e);
      rethrow;
    }
  }
}
