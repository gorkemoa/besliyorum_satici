/// Model for adding a product to sell (sellProduct API)
/// POST: service/user/account/products/sellProduct
/// 
/// Model for updating a product already on sale (sellUpdateProduct API)
/// POST: service/user/account/products/sellUpdateProduct

// ==================== REQUEST MODELS ====================

class SellProductRequestModel {
  final String userToken;
  final int productID;
  final List<SellProductVariant> variants;

  SellProductRequestModel({
    required this.userToken,
    required this.productID,
    required this.variants,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'productID': productID,
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }
}

class SellProductVariant {
  final int variantID;
  final int variantQty;
  final int variantStock;
  final double variantCurrencyPrice;
  final double variantDiscountPrice;

  SellProductVariant({
    required this.variantID,
    required this.variantQty,
    required this.variantStock,
    required this.variantCurrencyPrice,
    required this.variantDiscountPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'variantID': variantID,
      'variantQty': variantQty,
      'variantStock': variantStock,
      'variantCurrencyPrice': variantCurrencyPrice,
      'variantDiscountPrice': variantDiscountPrice,
    };
  }
}

// ==================== UPDATE REQUEST MODELS ====================

class UpdateSellProductRequestModel {
  final String userToken;
  final int productID;
  final List<UpdateSellProductVariant> variants;

  UpdateSellProductRequestModel({
    required this.userToken,
    required this.productID,
    required this.variants,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'productID': productID,
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }
}

class UpdateSellProductVariant {
  final int variantID;
  final int variantQty;
  final int variantStock;
  final double variantCurrencyPrice;
  final double variantDiscountPrice;
  final int isPublished; // 1: yayında, 0: yayında değil
  final int isRemove; // 1: satıştan çıkart, 0: çıkartma

  UpdateSellProductVariant({
    required this.variantID,
    required this.variantQty,
    required this.variantStock,
    required this.variantCurrencyPrice,
    required this.variantDiscountPrice,
    this.isPublished = 1,
    this.isRemove = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'variantID': variantID,
      'variantQty': variantQty,
      'variantStock': variantStock,
      'variantCurrencyPrice': variantCurrencyPrice,
      'variantDiscountPrice': variantDiscountPrice,
      'isPublished': isPublished,
      'isRemove': isRemove,
    };
  }
}

// ==================== RESPONSE MODELS ====================

class SellProductResponseModel {
  final bool error;
  final bool success;
  final String? message;

  SellProductResponseModel({
    required this.error,
    required this.success,
    this.message,
  });

  factory SellProductResponseModel.fromJson(Map<String, dynamic> json) {
    return SellProductResponseModel(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['message'],
    );
  }
}
