import 'package:flutter/material.dart';
import 'package:besliyorum_satici/models/products/product_detail_model.dart';
import 'package:besliyorum_satici/models/products/sell_product_model.dart';
import 'package:besliyorum_satici/services/product_service.dart';

/// Varyasyon seçimi için yardımcı model
class VariantSelection {
  final int variantID;
  final String variantTitle;
  int quantity;
  int stock;
  double price;
  double discountPrice;
  bool isSelected;
  bool isPublished; // Yayında mı?
  bool isRemove; // Satıştan çıkart

  VariantSelection({
    required this.variantID,
    required this.variantTitle,
    this.quantity = 1,
    this.stock = 0,
    this.price = 0.0,
    this.discountPrice = 0.0,
    this.isSelected = false,
    this.isPublished = true,
    this.isRemove = false,
  });
}

/// Ürün detay sayfası için ViewModel
class ProductDetailViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSelling = false;
  bool get isSelling => _isSelling;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  ProductDetailData? _productDetail;
  ProductDetailData? get productDetail => _productDetail;

  // Varyasyon seçimleri
  Map<int, VariantSelection> _variantSelections = {};
  Map<int, VariantSelection> get variantSelections => _variantSelections;

  // Seçili varyasyon sayısı (satışta olmayanlar için)
  int get selectedVariantCount =>
      _variantSelections.values.where((v) => v.isSelected).length;

  // Seçili varyasyonlar listesi (satışta olmayanlar için)
  List<VariantSelection> get selectedVariants =>
      _variantSelections.values.where((v) => v.isSelected).toList();

  // Satışta olan varyasyonların listesi
  List<ProductVariation> get sellingVariants {
    if (_productDetail == null) return [];
    return _productDetail!.variations.where((v) => v.isSelling).toList();
  }

  // Düzenlenmiş satışta olan varyasyonlar (güncelleme için)
  Map<int, VariantSelection> _editedSellingVariants = {};
  Map<int, VariantSelection> get editedSellingVariants => _editedSellingVariants;

  // Düzenlenmiş varyasyon var mı?
  bool get hasEditedSellingVariants => _editedSellingVariants.isNotEmpty;

  /// Ürün detayını yükler
  Future<void> loadProductDetail(String userToken, int productID) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _productService.getProductDetail(
        userToken,
        productID,
      );

      if (response.success && response.data != null) {
        _productDetail = response.data;
        _errorMessage = null;
        _initializeVariantSelections();
      } else {
        _errorMessage = response.message ?? 'Ürün detayı yüklenemedi';
        _productDetail = null;
      }
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: $e';
      _productDetail = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Varyasyon seçimlerini başlat
  void _initializeVariantSelections() {
    _variantSelections.clear();
    if (_productDetail != null) {
      for (var variation in _productDetail!.variations) {
        _variantSelections[variation.variantID] = VariantSelection(
          variantID: variation.variantID,
          variantTitle: variation.variantTitle,
          quantity: 1,
          stock: 10, // Varsayılan stok
          price: 0.0,
          discountPrice: 0.0,
          isSelected: false,
        );
      }
    }
  }

  /// Varyasyon seçimini toggle et
  void toggleVariantSelection(int variantID) {
    if (_variantSelections.containsKey(variantID)) {
      _variantSelections[variantID]!.isSelected =
          !_variantSelections[variantID]!.isSelected;
      notifyListeners();
    }
  }

  /// Varyasyon değerini güncelle
  void updateVariantValue(
    int variantID, {
    int? quantity,
    int? stock,
    double? price,
    double? discountPrice,
  }) {
    if (_variantSelections.containsKey(variantID)) {
      final selection = _variantSelections[variantID]!;
      if (quantity != null) selection.quantity = quantity;
      if (stock != null) selection.stock = stock;
      if (price != null) selection.price = price;
      if (discountPrice != null) selection.discountPrice = discountPrice;
      notifyListeners();
    }
  }

  /// Satışta olan varyasyonu düzenle (güncelleme için)
  void updateSellingVariant(
    int variantID, {
    int? quantity,
    int? stock,
    double? price,
    double? discountPrice,
    bool? isPublished,
    bool? isRemove,
  }) {
    // Varyasyonu bul
    final variation = _productDetail?.variations
        .firstWhere((v) => v.variantID == variantID, orElse: () => throw Exception('Variant not found'));
    
    if (variation == null) return;
    
    final sellerData = variation.sellerData;
    if (sellerData == null) return;

    // Eğer daha önce düzenlenmediyse, mevcut değerleri ile oluştur
    if (!_editedSellingVariants.containsKey(variantID)) {
      _editedSellingVariants[variantID] = VariantSelection(
        variantID: variantID,
        variantTitle: variation.variantTitle,
        quantity: sellerData.quantity,
        stock: sellerData.stock,
        price: sellerData.price,
        discountPrice: sellerData.discountPrice,
        isSelected: true,
        isPublished: sellerData.isPublished,
        isRemove: false,
      );
    }

    final selection = _editedSellingVariants[variantID]!;
    if (quantity != null) selection.quantity = quantity;
    if (stock != null) selection.stock = stock;
    if (price != null) selection.price = price;
    if (discountPrice != null) selection.discountPrice = discountPrice;
    if (isPublished != null) selection.isPublished = isPublished;
    if (isRemove != null) selection.isRemove = isRemove;
    
    notifyListeners();
  }

  /// Satıştan çıkartılacak varyasyonu işaretle
  void toggleRemoveSellingVariant(int variantID) {
    final variation = _productDetail?.variations
        .firstWhere((v) => v.variantID == variantID, orElse: () => throw Exception('Variant not found'));
    
    if (variation == null) return;
    
    final sellerData = variation.sellerData;
    if (sellerData == null) return;

    if (!_editedSellingVariants.containsKey(variantID)) {
      _editedSellingVariants[variantID] = VariantSelection(
        variantID: variantID,
        variantTitle: variation.variantTitle,
        quantity: sellerData.quantity,
        stock: sellerData.stock,
        price: sellerData.price,
        discountPrice: sellerData.discountPrice,
        isSelected: true,
        isPublished: sellerData.isPublished,
        isRemove: true,
      );
    } else {
      _editedSellingVariants[variantID]!.isRemove = 
          !_editedSellingVariants[variantID]!.isRemove;
    }
    
    notifyListeners();
  }

  /// Yayın durumunu değiştir
  void togglePublishSellingVariant(int variantID) {
    final variation = _productDetail?.variations
        .firstWhere((v) => v.variantID == variantID, orElse: () => throw Exception('Variant not found'));
    
    if (variation == null) return;
    
    final sellerData = variation.sellerData;
    if (sellerData == null) return;

    if (!_editedSellingVariants.containsKey(variantID)) {
      _editedSellingVariants[variantID] = VariantSelection(
        variantID: variantID,
        variantTitle: variation.variantTitle,
        quantity: sellerData.quantity,
        stock: sellerData.stock,
        price: sellerData.price,
        discountPrice: sellerData.discountPrice,
        isSelected: true,
        isPublished: !sellerData.isPublished,
        isRemove: false,
      );
    } else {
      _editedSellingVariants[variantID]!.isPublished = 
          !_editedSellingVariants[variantID]!.isPublished;
    }
    
    notifyListeners();
  }

  /// Düzenlenmiş satışta varyasyonu temizle
  void clearEditedSellingVariant(int variantID) {
    _editedSellingVariants.remove(variantID);
    notifyListeners();
  }

  /// Ürünü satışa ekle
  Future<bool> sellProduct(String userToken, int productID) async {
    // Seçili varyasyonları kontrol et
    final selected = selectedVariants;
    if (selected.isEmpty) {
      _errorMessage = 'Lütfen en az bir varyasyon seçin';
      notifyListeners();
      return false;
    }

    // Fiyat kontrolü
    for (var variant in selected) {
      if (variant.price <= 0) {
        _errorMessage = '${variant.variantTitle} için fiyat girmelisiniz';
        notifyListeners();
        return false;
      }
    }

    _isSelling = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final request = SellProductRequestModel(
        userToken: userToken,
        productID: productID,
        variants: selected.map((v) => SellProductVariant(
          variantID: v.variantID,
          variantQty: v.quantity,
          variantStock: v.stock,
          variantCurrencyPrice: v.price,
          variantDiscountPrice: v.discountPrice > 0 ? v.discountPrice : v.price,
        )).toList(),
      );

      final response = await _productService.sellProduct(request);

      if (response.success) {
        _successMessage = response.message ?? 'Ürün başarıyla satışa eklendi';
        // Seçimleri temizle
        _initializeVariantSelections();
        // Ürün detayını yeniden yükle
        await loadProductDetail(userToken, productID);
        return true;
      } else {
        _errorMessage = response.message ?? 'Ürün satışa eklenemedi';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: $e';
      return false;
    } finally {
      _isSelling = false;
      notifyListeners();
    }
  }

  /// Satıştaki ürünü güncelle
  Future<bool> updateSellProduct(String userToken, int productID) async {
    // Düzenlenmiş varyasyonları kontrol et
    if (_editedSellingVariants.isEmpty) {
      _errorMessage = 'Güncellenecek varyasyon bulunamadı';
      notifyListeners();
      return false;
    }

    // Fiyat kontrolü (satıştan çıkartılmayacaklar için)
    for (var variant in _editedSellingVariants.values) {
      if (!variant.isRemove && variant.price <= 0) {
        _errorMessage = '${variant.variantTitle} için fiyat girmelisiniz';
        notifyListeners();
        return false;
      }
    }

    _isUpdating = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final request = UpdateSellProductRequestModel(
        userToken: userToken,
        productID: productID,
        variants: _editedSellingVariants.values.map((v) => UpdateSellProductVariant(
          variantID: v.variantID,
          variantQty: v.quantity,
          variantStock: v.stock,
          variantCurrencyPrice: v.price,
          variantDiscountPrice: v.discountPrice > 0 ? v.discountPrice : v.price,
          isPublished: v.isPublished ? 1 : 0,
          isRemove: v.isRemove ? 1 : 0,
        )).toList(),
      );

      final response = await _productService.updateSellProduct(request);

      if (response.success) {
        _successMessage = response.message ?? 'Ürün başarıyla güncellendi';
        // Düzenlemeleri temizle
        _editedSellingVariants.clear();
        // Ürün detayını yeniden yükle
        await loadProductDetail(userToken, productID);
        return true;
      } else {
        _errorMessage = response.message ?? 'Ürün güncellenemedi';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: $e';
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Mesajları temizle
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Ürün detayını temizler
  void clearProductDetail() {
    _productDetail = null;
    _errorMessage = null;
    _successMessage = null;
    _variantSelections.clear();
    _editedSellingVariants.clear();
    notifyListeners();
  }
}
