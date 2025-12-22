import 'package:flutter/foundation.dart';
import 'package:besliyorum_satici/models/products/product_model.dart';
import 'package:besliyorum_satici/models/products/category_model.dart';
import '../services/product_service.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  // === Satıcı Ürünleri State ===
  bool _isSellerProductsLoading = false;
  bool get isSellerProductsLoading => _isSellerProductsLoading;

  bool _isSellerProductsLoadingMore = false;
  bool get isSellerProductsLoadingMore => _isSellerProductsLoadingMore;

  String? _sellerProductsErrorMessage;
  String? get sellerProductsErrorMessage => _sellerProductsErrorMessage;

  List<SellerProduct> _sellerProducts = [];
  List<SellerProduct> get sellerProducts => _sellerProducts;

  PaginationInfo? _sellerProductsPagination;
  PaginationInfo? get sellerProductsPagination => _sellerProductsPagination;

  int _sellerProductsCurrentPage = 1;
  int get sellerProductsCurrentPage => _sellerProductsCurrentPage;

  bool _sellerProductsHasMore = true;
  bool get sellerProductsHasMore => _sellerProductsHasMore;

  String? _sellerProductsSearch;
  int? _sellerProductsCatID;

  // === Katalog Ürünleri State ===
  bool _isCatalogProductsLoading = false;
  bool get isCatalogProductsLoading => _isCatalogProductsLoading;

  bool _isCatalogProductsLoadingMore = false;
  bool get isCatalogProductsLoadingMore => _isCatalogProductsLoadingMore;

  String? _catalogProductsErrorMessage;
  String? get catalogProductsErrorMessage => _catalogProductsErrorMessage;

  List<CatalogProduct> _catalogProducts = [];
  List<CatalogProduct> get catalogProducts => _catalogProducts;

  PaginationInfo? _catalogProductsPagination;
  PaginationInfo? get catalogProductsPagination => _catalogProductsPagination;

  int _catalogProductsCurrentPage = 1;
  int get catalogProductsCurrentPage => _catalogProductsCurrentPage;

  bool _catalogProductsHasMore = true;
  bool get catalogProductsHasMore => _catalogProductsHasMore;

  String? _catalogProductsSearch;
  int? _catalogProductsCatID;

  // === Kategoriler State ===
  bool _isCategoriesLoading = false;
  bool get isCategoriesLoading => _isCategoriesLoading;

  String? _categoriesErrorMessage;
  String? get categoriesErrorMessage => _categoriesErrorMessage;

  List<DetailedCategory> _categories = [];
  List<DetailedCategory> get categories => _categories;

  // ===========================
  // Satıcı Ürünleri Metodları
  // ===========================

  /// Satıcı ürünlerini ilk sayfa için yükler
  Future<void> getSellerProducts(
    String userToken, {
    String? search,
    int? catID,
    bool refresh = false,
  }) async {
    // Yenileme yapılıyorsa veya ilk yükleme ise
    if (refresh || _sellerProducts.isEmpty) {
      _sellerProductsCurrentPage = 1;
      _sellerProductsHasMore = true;
      _sellerProducts = [];
    }

    _sellerProductsSearch = search;
    _sellerProductsCatID = catID;

    _isSellerProductsLoading = true;
    _sellerProductsErrorMessage = null;
    notifyListeners();

    try {
      final response = await _productService.getSellerProducts(
        userToken,
        page: 1,
        search: search,
        catID: catID,
      );

      if (response.success && response.data != null) {
        _sellerProducts = response.data!.products;
        _sellerProductsPagination = response.data!.pagination;
        _sellerProductsCurrentPage = 1;
        _sellerProductsHasMore = response.data!.pagination.hasNextPage;
      } else {
        _sellerProductsErrorMessage = 'Ürünler yüklenemedi';
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        _sellerProductsErrorMessage = '403_LOGOUT';
      } else {
        _sellerProductsErrorMessage = e.toString();
      }
    } finally {
      _isSellerProductsLoading = false;
      notifyListeners();
    }
  }

  /// Satıcı ürünlerinin sonraki sayfasını yükler (infinite scroll)
  Future<void> loadMoreSellerProducts(String userToken) async {
    // Daha fazla yüklenecek ürün yoksa veya zaten yükleniyorsa çık
    if (!_sellerProductsHasMore || _isSellerProductsLoadingMore) return;

    _isSellerProductsLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _sellerProductsCurrentPage + 1;
      final response = await _productService.getSellerProducts(
        userToken,
        page: nextPage,
        search: _sellerProductsSearch,
        catID: _sellerProductsCatID,
      );

      if (response.success && response.data != null) {
        if (response.data!.products.isEmpty) {
          // Boş sayfa döndü, daha fazla ürün yok
          _sellerProductsHasMore = false;
        } else {
          _sellerProducts.addAll(response.data!.products);
          _sellerProductsPagination = response.data!.pagination;
          _sellerProductsCurrentPage = nextPage;
          _sellerProductsHasMore = response.data!.pagination.hasNextPage;
        }
      } else {
        // 417 veya hata durumu - daha fazla sayfa yok
        _sellerProductsHasMore = false;
      }
    } catch (e) {
      // Hata durumunda daha fazla yüklemeyi durdur
      _sellerProductsHasMore = false;
    } finally {
      _isSellerProductsLoadingMore = false;
      notifyListeners();
    }
  }

  /// Satıcı ürünlerini filtrele
  void filterSellerProducts(String userToken, {String? search, int? catID}) {
    _sellerProductsSearch = search;
    _sellerProductsCatID = catID;
    getSellerProducts(userToken, search: search, catID: catID, refresh: true);
  }

  /// Satıcı ürünleri state'ini sıfırla
  void resetSellerProducts() {
    _sellerProducts = [];
    _sellerProductsPagination = null;
    _sellerProductsCurrentPage = 1;
    _sellerProductsHasMore = true;
    _sellerProductsSearch = null;
    _sellerProductsCatID = null;
    _sellerProductsErrorMessage = null;
    _isSellerProductsLoading = false;
    _isSellerProductsLoadingMore = false;
  }

  // ===========================
  // Katalog Ürünleri Metodları
  // ===========================

  /// Katalog ürünlerini ilk sayfa için yükler
  Future<void> getCatalogProducts(
    String userToken, {
    String? search,
    int? catID,
    bool refresh = false,
  }) async {
    // Yenileme yapılıyorsa veya ilk yükleme ise
    if (refresh || _catalogProducts.isEmpty) {
      _catalogProductsCurrentPage = 1;
      _catalogProductsHasMore = true;
      _catalogProducts = [];
    }

    _catalogProductsSearch = search;
    _catalogProductsCatID = catID;

    _isCatalogProductsLoading = true;
    _catalogProductsErrorMessage = null;
    notifyListeners();

    try {
      final response = await _productService.getCatalogProducts(
        userToken,
        page: 1,
        search: search,
        catID: catID,
      );

      if (response.success && response.data != null) {
        _catalogProducts = response.data!.products;
        _catalogProductsPagination = response.data!.pagination;
        _catalogProductsCurrentPage = 1;
        _catalogProductsHasMore = response.data!.pagination.hasNextPage;
      } else {
        _catalogProductsErrorMessage = 'Ürünler yüklenemedi';
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        _catalogProductsErrorMessage = '403_LOGOUT';
      } else {
        _catalogProductsErrorMessage = e.toString();
      }
    } finally {
      _isCatalogProductsLoading = false;
      notifyListeners();
    }
  }

  /// Katalog ürünlerinin sonraki sayfasını yükler (infinite scroll)
  Future<void> loadMoreCatalogProducts(String userToken) async {
    // Daha fazla yüklenecek ürün yoksa veya zaten yükleniyorsa çık
    if (!_catalogProductsHasMore || _isCatalogProductsLoadingMore) return;

    _isCatalogProductsLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _catalogProductsCurrentPage + 1;
      final response = await _productService.getCatalogProducts(
        userToken,
        page: nextPage,
        search: _catalogProductsSearch,
        catID: _catalogProductsCatID,
      );

      if (response.success && response.data != null) {
        if (response.data!.products.isEmpty) {
          // Boş sayfa döndü, daha fazla ürün yok
          _catalogProductsHasMore = false;
        } else {
          _catalogProducts.addAll(response.data!.products);
          _catalogProductsPagination = response.data!.pagination;
          _catalogProductsCurrentPage = nextPage;
          _catalogProductsHasMore = response.data!.pagination.hasNextPage;
        }
      } else {
        // 417 veya hata durumu - daha fazla sayfa yok
        _catalogProductsHasMore = false;
      }
    } catch (e) {
      // Hata durumunda daha fazla yüklemeyi durdur
      _catalogProductsHasMore = false;
    } finally {
      _isCatalogProductsLoadingMore = false;
      notifyListeners();
    }
  }

  /// Katalog ürünlerini filtrele
  void filterCatalogProducts(String userToken, {String? search, int? catID}) {
    _catalogProductsSearch = search;
    _catalogProductsCatID = catID;
    getCatalogProducts(userToken, search: search, catID: catID, refresh: true);
  }

  /// Katalog ürünleri state'ini sıfırla
  void resetCatalogProducts() {
    _catalogProducts = [];
    _catalogProductsPagination = null;
    _catalogProductsCurrentPage = 1;
    _catalogProductsHasMore = true;
    _catalogProductsSearch = null;
    _catalogProductsCatID = null;
    _catalogProductsErrorMessage = null;
    _isCatalogProductsLoading = false;
    _isCatalogProductsLoadingMore = false;
  }

  /// Kategorileri yükler
  Future<void> getCategories(String userToken) async {
    if (_categories.isNotEmpty) return;

    _isCategoriesLoading = true;
    _categoriesErrorMessage = null;
    notifyListeners();

    try {
      final response = await _productService.getCategories(userToken);

      if (response.success && response.data != null) {
        _categories = response.data!;
      } else {
        _categoriesErrorMessage = 'Kategoriler yüklenemedi';
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        _categoriesErrorMessage = '403_LOGOUT';
      } else {
        _categoriesErrorMessage = 'Bir hata oluştu';
      }
    } finally {
      _isCategoriesLoading = false;
      notifyListeners();
    }
  }

  /// Tüm state'i sıfırla
  void resetState() {
    resetSellerProducts();
    resetCatalogProducts();
    _categories = [];
    _categoriesErrorMessage = null;
    _isCategoriesLoading = false;
    notifyListeners();
  }
}
