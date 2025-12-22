/// Ortak Category modeli
class ProductCategory {
  final int catID;
  final String catName;

  ProductCategory({
    required this.catID,
    required this.catName,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      catID: json['catID'] ?? 0,
      catName: json['catName'] ?? '',
    );
  }
}

/// Satıcı ürünleri için varyant modeli (fiyat ve stok bilgisi içerir)
class SellerProductVariation {
  final int variantID;
  final String variantTitle;
  final String variantBarcode;
  final int quantity;
  final int stock;
  final String price;
  final String discountPrice;
  final bool isPublished;

  SellerProductVariation({
    required this.variantID,
    required this.variantTitle,
    required this.variantBarcode,
    required this.quantity,
    required this.stock,
    required this.price,
    required this.discountPrice,
    required this.isPublished,
  });

  factory SellerProductVariation.fromJson(Map<String, dynamic> json) {
    return SellerProductVariation(
      variantID: json['variantID'] ?? 0,
      variantTitle: json['variantTitle'] ?? '',
      variantBarcode: json['variantBarcode'] ?? '',
      quantity: json['quantity'] ?? 0,
      stock: json['stock'] ?? 0,
      price: json['price'] ?? '',
      discountPrice: json['discountPrice'] ?? '',
      isPublished: json['isPublished'] ?? false,
    );
  }
}

/// Katalog ürünleri için varyant modeli (sadece temel bilgiler)
class CatalogProductVariation {
  final int variantID;
  final String variantTitle;
  final String variantBarcode;

  CatalogProductVariation({
    required this.variantID,
    required this.variantTitle,
    required this.variantBarcode,
  });

  factory CatalogProductVariation.fromJson(Map<String, dynamic> json) {
    return CatalogProductVariation(
      variantID: json['variantID'] ?? 0,
      variantTitle: json['variantTitle'] ?? '',
      variantBarcode: json['variantBarcode'] ?? '',
    );
  }
}

/// Satıcının kendi ürünleri için model
class SellerProduct {
  final int productID;
  final String productTitle;
  final String productCode;
  final String productMainImage;
  final String productThumbImage;
  final int totalVariations;
  final int sellingVariations;
  final List<SellerProductVariation> variations;
  final List<ProductCategory> categories;

  SellerProduct({
    required this.productID,
    required this.productTitle,
    required this.productCode,
    required this.productMainImage,
    required this.productThumbImage,
    required this.totalVariations,
    required this.sellingVariations,
    required this.variations,
    required this.categories,
  });

  factory SellerProduct.fromJson(Map<String, dynamic> json) {
    return SellerProduct(
      productID: json['productID'] ?? 0,
      productTitle: json['productTitle'] ?? '',
      productCode: json['productCode'] ?? '',
      productMainImage: json['productMainImage'] ?? '',
      productThumbImage: json['productThumbImage'] ?? '',
      totalVariations: json['totalVariations'] ?? 0,
      sellingVariations: json['sellingVariations'] ?? 0,
      variations: (json['variations'] as List<dynamic>?)
              ?.map((e) => SellerProductVariation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Katalog ürünleri için model
class CatalogProduct {
  final int productID;
  final String productTitle;
  final String productCode;
  final String productMainImage;
  final String productThumbImage;
  final bool isSelling;
  final int totalVariations;
  final int sellingVariations;
  final List<CatalogProductVariation> variations;
  final List<ProductCategory> categories;

  CatalogProduct({
    required this.productID,
    required this.productTitle,
    required this.productCode,
    required this.productMainImage,
    required this.productThumbImage,
    required this.isSelling,
    required this.totalVariations,
    required this.sellingVariations,
    required this.variations,
    required this.categories,
  });

  factory CatalogProduct.fromJson(Map<String, dynamic> json) {
    return CatalogProduct(
      productID: json['productID'] ?? 0,
      productTitle: json['productTitle'] ?? '',
      productCode: json['productCode'] ?? '',
      productMainImage: json['productMainImage'] ?? '',
      productThumbImage: json['productThumbImage'] ?? '',
      isSelling: json['isSelling'] ?? false,
      totalVariations: json['totalVariations'] ?? 0,
      sellingVariations: json['sellingVariations'] ?? 0,
      variations: (json['variations'] as List<dynamic>?)
              ?.map((e) => CatalogProductVariation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Sayfalama bilgisi için ortak model
class PaginationInfo {
  final int currentPage;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final int itemCount;
  final bool hasNextPage;

  PaginationInfo({
    required this.currentPage,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.itemCount,
    required this.hasNextPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      perPage: json['perPage'] ?? 20,
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      itemCount: json['itemCount'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
}

/// Satıcı ürünleri response data modeli
class SellerProductsData {
  final PaginationInfo pagination;
  final List<SellerProduct> products;

  SellerProductsData({
    required this.pagination,
    required this.products,
  });

  factory SellerProductsData.fromJson(Map<String, dynamic> json) {
    return SellerProductsData(
      pagination: PaginationInfo.fromJson(json),
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => SellerProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Katalog ürünleri response data modeli
class CatalogProductsData {
  final PaginationInfo pagination;
  final List<CatalogProduct> products;

  CatalogProductsData({
    required this.pagination,
    required this.products,
  });

  factory CatalogProductsData.fromJson(Map<String, dynamic> json) {
    return CatalogProductsData(
      pagination: PaginationInfo.fromJson(json),
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => CatalogProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Satıcı ürünleri API response modeli
class SellerProductsResponseModel {
  final bool error;
  final bool success;
  final SellerProductsData? data;
  final String? code200;

  SellerProductsResponseModel({
    required this.error,
    required this.success,
    this.data,
    this.code200,
  });

  factory SellerProductsResponseModel.fromJson(Map<String, dynamic> json) {
    return SellerProductsResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? SellerProductsData.fromJson(json['data']) : null,
      code200: json['200'],
    );
  }
}

/// Katalog ürünleri API response modeli
class CatalogProductsResponseModel {
  final bool error;
  final bool success;
  final CatalogProductsData? data;
  final String? code200;

  CatalogProductsResponseModel({
    required this.error,
    required this.success,
    this.data,
    this.code200,
  });

  factory CatalogProductsResponseModel.fromJson(Map<String, dynamic> json) {
    return CatalogProductsResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? CatalogProductsData.fromJson(json['data']) : null,
      code200: json['200'],
    );
  }
}
