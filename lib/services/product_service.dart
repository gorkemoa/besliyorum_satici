import 'dart:convert';
import 'package:logger/logger.dart';

import 'package:besliyorum_satici/models/products/product_model.dart';
import 'package:besliyorum_satici/models/products/category_model.dart';
import '../core/constants/app_constants.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();

  /// Satıcının kendi ürünlerini getirir
  /// [userToken] - Kullanıcı token'ı
  /// [page] - Sayfa numarası
  /// [search] - Arama sorgusu (opsiyonel)
  /// [catID] - Kategori ID'si (opsiyonel)
  Future<SellerProductsResponseModel> getSellerProducts(
    String userToken, {
    int page = 1,
    String? search,
    int? catID,
  }) async {
    try {
      String endpoint = '${Endpoints.sellerProducts}?userToken=$userToken&page=$page';

      if (search != null && search.isNotEmpty) {
        endpoint += '&search=$search';
      }
      if (catID != null) {
        endpoint += '&catID=$catID';
      }

      final response = await _apiService.get(endpoint);

      // 417 durumu sayfa sonu anlamına gelir
      if (response.statusCode == 417) {
        return SellerProductsResponseModel(
          error: false,
          success: true,
          data: SellerProductsData(
            pagination: PaginationInfo(
              currentPage: page,
              perPage: 20,
              totalItems: 0,
              totalPages: page - 1,
              itemCount: 0,
              hasNextPage: false,
            ),
            products: [],
          ),
        );
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return SellerProductsResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error fetching seller products', error: e);
      rethrow;
    }
  }

  /// Katalog ürünlerini getirir
  /// [userToken] - Kullanıcı token'ı
  /// [page] - Sayfa numarası
  /// [search] - Arama sorgusu (opsiyonel)
  /// [catID] - Kategori ID'si (opsiyonel)
  Future<CatalogProductsResponseModel> getCatalogProducts(
    String userToken, {
    int page = 1,
    String? search,
    int? catID,
  }) async {
    try {
      String endpoint = '${Endpoints.catalogProducts}?userToken=$userToken&page=$page';

      if (search != null && search.isNotEmpty) {
        endpoint += '&search=$search';
      }
      if (catID != null) {
        endpoint += '&catID=$catID';
      }

      final response = await _apiService.get(endpoint);

      // 417 durumu sayfa sonu anlamına gelir
      if (response.statusCode == 417) {
        return CatalogProductsResponseModel(
          error: false,
          success: true,
          data: CatalogProductsData(
            pagination: PaginationInfo(
              currentPage: page,
              perPage: 20,
              totalItems: 0,
              totalPages: page - 1,
              itemCount: 0,
              hasNextPage: false,
            ),
            products: [],
          ),
        );
      }

      // 410 veya 200 durumunda normal response işle
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return CatalogProductsResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error fetching catalog products', error: e);
      rethrow;
    }
  }

  /// Ürün kategorilerini getirir
  Future<CategoryResponseModel> getCategories(String userToken) async {
    try {
      final response = await _apiService.get('${Endpoints.categories}?userToken=$userToken');
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return CategoryResponseModel.fromJson(responseData);
    } catch (e) {
      _logger.e('Error fetching categories', error: e);
      rethrow;
    }
  }
}
