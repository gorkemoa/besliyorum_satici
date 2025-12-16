import 'dart:convert';
import 'package:logger/logger.dart';

import 'package:besliyorum_satici/models/home/home_model.dart';
import 'api_service.dart';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

class UsersService {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();

  Future<HomeResponseModel> getUserAccount(int userId, String userToken) async {
    try {
      // The endpoint defined in the request is 'service/user/account/id/{userid}'
      // assuming Endpoints in app_constants might not have this yet, or I should construct it.
      // Re-checking app_constants might be useful, but for now I will hardcode or assume flexible endpoint.
      // Wait, I should check existing Endpoints. For now I will build the URL manually if needed or add to Endpoints later.
      // Detailed check on request: GetUser {{API_URL}}service/user/account/id/{userid}

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
}
