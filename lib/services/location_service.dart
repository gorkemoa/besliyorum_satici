import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../models/auth/location_model.dart';
import 'api_service.dart';

class LocationService {
  final ApiService _apiService = ApiService();

  Future<List<CityModel>> getCities() async {
    try {
      final response = await _apiService.get(Endpoints.cities);
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final locationResponse = LocationResponseModel<CityModel>.fromJson(
        responseData,
        (json) => CityModel.fromJson(json),
        'cities',
      );

      return locationResponse.data;
    } catch (e) {
      throw Exception('Şehirler yüklenemedi: $e');
    }
  }

  Future<List<DistrictModel>> getDistricts(int cityId) async {
    try {
      // Endpoint: service/general/general/{cityNO}/districts
      final response = await _apiService.get(
        '${Endpoints.districts}/$cityId/districts',
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final locationResponse = LocationResponseModel<DistrictModel>.fromJson(
        responseData,
        (json) => DistrictModel.fromJson(json),
        'districts',
      );

      return locationResponse.data;
    } catch (e) {
      throw Exception('İlçeler yüklenemedi: $e');
    }
  }

  Future<List<NeighborhoodModel>> getNeighborhoods(int districtId) async {
    try {
      // Endpoint: service/general/general/{districtNO}/neighbourhood
      final response = await _apiService.get(
        '${Endpoints.neighborhoods}/$districtId/neighbourhood',
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final locationResponse =
          LocationResponseModel<NeighborhoodModel>.fromJson(
            responseData,
            (json) => NeighborhoodModel.fromJson(json),
            'neighborhoods',
          );

      return locationResponse.data;
    } catch (e) {
      throw Exception('Mahalleler yüklenemedi: $e');
    }
  }
}
