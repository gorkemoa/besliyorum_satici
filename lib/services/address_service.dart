import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../models/address/get_addresses_response.dart';
import '../models/address/city_model.dart';
import '../models/address/district_model.dart';
import '../models/address/neighborhood_model.dart';
import '../models/address/address_type_model.dart';
import '../models/address/add_address_request.dart';
import '../models/address/update_address_request.dart';
import 'api_service.dart';

class AddressService {
  final ApiService _apiService = ApiService();

  /// Fetches the list of addresses for the authenticated user
  ///
  /// [userToken] - The user's authentication token
  /// Returns [GetAddressesResponse] containing list of addresses
  /// Throws exception on network error or invalid response
  Future<GetAddressesResponse> getAddresses(String userToken) async {
    try {
      final endpoint = '${Endpoints.addressList}?userToken=$userToken';
      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return GetAddressesResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 417) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(
          jsonResponse['message'] ?? 'Adresler yüklenirken bir hata oluştu',
        );
      } else {
        throw Exception('Adresler yüklenirken bir hata oluştu');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Adds a new address for the authenticated user
  Future<bool> addAddress(AddAddressRequest request) async {
    try {
      final response = await _apiService.post(
        Endpoints.addressAdd,
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonResponse['success'] == true;
      } else if (response.statusCode == 417) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(
          jsonResponse['message'] ?? 'Adres eklenirken bir hata oluştu',
        );
      } else {
        throw Exception('Adres eklenirken bir hata oluştu');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing address
  Future<bool> updateAddress(UpdateAddressRequest request) async {
    try {
      final response = await _apiService.post(
        Endpoints.addressUpdate,
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonResponse['success'] == true;
      } else if (response.statusCode == 417) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(
          jsonResponse['message'] ?? 'Adres güncellenirken bir hata oluştu',
        );
      } else {
        throw Exception('Adres güncellenirken bir hata oluştu');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches address types (Fatura, Sevkiyat, İade)
  Future<List<AddressTypeModel>> getAddressTypes() async {
    try {
      final response = await _apiService.get(Endpoints.addressTypes);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data'] as List;
        return data
            .map(
              (item) => AddressTypeModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else if (response.statusCode == 417) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(
          jsonResponse['message'] ??
              'Adres tipleri yüklenirken bir hata oluştu',
        );
      } else {
        throw Exception('Adres tipleri yüklenirken bir hata oluştu');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches all cities
  Future<List<CityModel>> getCities() async {
    try {
      final response = await _apiService.get(Endpoints.cities);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data']['cities'] as List;
        return data
            .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 417) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(
          jsonResponse['message'] ?? 'Şehirler yüklenirken bir hata oluştu',
        );
      } else {
        throw Exception('Şehirler yüklenirken bir hata oluştu');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches districts for a specific city
  Future<List<DistrictModel>> getDistricts(int cityNO) async {
    try {
      final endpoint = '${Endpoints.districts}/$cityNO/districts';
      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data']['districts'] as List;
        return data
            .map((item) => DistrictModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 417) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(
          jsonResponse['message'] ?? 'İlçeler yüklenirken bir hata oluştu',
        );
      } else {
        throw Exception('İlçeler yüklenirken bir hata oluştu');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches neighborhoods for a specific district
  Future<List<NeighborhoodModel>> getNeighborhoods(int districtNO) async {
    try {
      final endpoint = '${Endpoints.neighborhoods}/$districtNO/neighbourhood';
      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data']['neighborhoods'] as List;
        return data
            .map(
              (item) =>
                  NeighborhoodModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else if (response.statusCode == 417) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(
          jsonResponse['message'] ?? 'Mahalleler yüklenirken bir hata oluştu',
        );
      } else {
        throw Exception('Mahalleler yüklenirken bir hata oluştu');
      }
    } catch (e) {
      rethrow;
    }
  }
}
