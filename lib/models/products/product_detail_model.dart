/// Ürün detay sayfası için model sınıfları

/// Ürün detay response modeli
class ProductDetailResponseModel {
  final bool error;
  final bool success;
  final ProductDetailData? data;
  final String? message;

  ProductDetailResponseModel({
    required this.error,
    required this.success,
    this.data,
    this.message,
  });

  factory ProductDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null
          ? ProductDetailData.fromJson(json['data'])
          : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'success': success,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

/// Ürün detay data sınıfı
class ProductDetailData {
  final int productID;
  final String productTitle;
  final String productCode;
  final String productDesc;
  final String productMainImage;
  final String productThumbImage;
  final int totalVariations;
  final List<ProductCategory> categories;
  final List<ProductVariation> variations;

  ProductDetailData({
    required this.productID,
    required this.productTitle,
    required this.productCode,
    required this.productDesc,
    required this.productMainImage,
    required this.productThumbImage,
    required this.totalVariations,
    required this.categories,
    required this.variations,
  });

  factory ProductDetailData.fromJson(Map<String, dynamic> json) {
    return ProductDetailData(
      productID: json['productID'] ?? 0,
      productTitle: json['productTitle'] ?? '',
      productCode: json['productCode'] ?? '',
      productDesc: json['productDesc'] ?? '',
      productMainImage: json['productMainImage'] ?? '',
      productThumbImage: json['productThumbImage'] ?? '',
      totalVariations: json['totalVariations'] ?? 0,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      variations:
          (json['variations'] as List<dynamic>?)
              ?.map((e) => ProductVariation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'productTitle': productTitle,
      'productCode': productCode,
      'productDesc': productDesc,
      'productMainImage': productMainImage,
      'productThumbImage': productThumbImage,
      'totalVariations': totalVariations,
      'categories': categories.map((e) => e.toJson()).toList(),
      'variations': variations.map((e) => e.toJson()).toList(),
    };
  }
}

/// Ürün kategori sınıfı
class ProductCategory {
  final int catID;
  final String catName;

  ProductCategory({required this.catID, required this.catName});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      catID: json['catID'] ?? 0,
      catName: json['catName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'catID': catID, 'catName': catName};
  }
}

/// Ürün varyasyon sınıfı
class ProductVariation {
  final int variantID;
  final String variantTitle;
  final String variantBarcode;
  final bool isSelling;
  final VariantSellerData? sellerData;

  ProductVariation({
    required this.variantID,
    required this.variantTitle,
    required this.variantBarcode,
    required this.isSelling,
    this.sellerData,
  });

  factory ProductVariation.fromJson(Map<String, dynamic> json) {
    // sellerData boş liste olarak gelebilir, bu durumu kontrol et
    VariantSellerData? sellerData;
    if (json['sellerData'] != null) {
      if (json['sellerData'] is Map<String, dynamic>) {
        sellerData = VariantSellerData.fromJson(json['sellerData']);
      } else if (json['sellerData'] is List && (json['sellerData'] as List).isEmpty) {
        sellerData = null;
      }
    }
    
    return ProductVariation(
      variantID: json['variantID'] ?? 0,
      variantTitle: json['variantTitle'] ?? '',
      variantBarcode: json['variantBarcode'] ?? '',
      isSelling: json['isSelling'] ?? false,
      sellerData: sellerData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variantID': variantID,
      'variantTitle': variantTitle,
      'variantBarcode': variantBarcode,
      'isSelling': isSelling,
      'sellerData': sellerData?.toJson(),
    };
  }
}

/// Varyasyon satıcı data sınıfı
class VariantSellerData {
  final int quantity;
  final int stock;
  final double price;
  final double discountPrice;
  final bool isPublished;

  VariantSellerData({
    required this.quantity,
    required this.stock,
    required this.price,
    required this.discountPrice,
    required this.isPublished,
  });

  factory VariantSellerData.fromJson(Map<String, dynamic> json) {
    return VariantSellerData(
      quantity: json['quantity'] ?? 0,
      stock: json['stock'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountPrice'] ?? 0).toDouble(),
      isPublished: json['isPublished'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'stock': stock,
      'price': price,
      'discountPrice': discountPrice,
      'isPublished': isPublished,
    };
  }
}
