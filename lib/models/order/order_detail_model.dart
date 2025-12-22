/// Sipariş detay API response modeli
class OrderDetailResponseModel {
  final bool error;
  final bool success;
  final OrderDetailData? data;
  final String? code200;

  OrderDetailResponseModel({
    required this.error,
    required this.success,
    this.data,
    this.code200,
  });

  factory OrderDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null
          ? OrderDetailData.fromJson(json['data'])
          : null,
      code200: json['200'],
    );
  }
}

/// Sipariş detay verisi
class OrderDetailData {
  final int orderID;
  final String orderCode;
  final String orderAmount;
  final String orderDiscount;
  final String orderDescription;
  final int orderStatus;
  final String orderStatusName;
  final String paymentType;
  final String orderDate;
  final String deliveryDate;
  final String invoice;
  final bool isConfirmable;
  final bool isCancelable;
  final bool isCreateLabel;
  final bool isTrackingCargo;
  final bool isMarkAllAsShipped;
  final bool isPrintCargoLabel;
  final bool isCanceled;
  final List<OrderProduct> products;
  final OrderAddress shippingAddress;
  final OrderAddress billingAddress;
  final String agreement;

  OrderDetailData({
    required this.orderID,
    required this.orderCode,
    required this.orderAmount,
    required this.orderDiscount,
    required this.orderDescription,
    required this.orderStatus,
    required this.orderStatusName,
    required this.paymentType,
    required this.orderDate,
    required this.deliveryDate,
    required this.invoice,
    required this.isConfirmable,
    required this.isCancelable,
    required this.isCreateLabel,
    required this.isTrackingCargo,
    required this.isMarkAllAsShipped,
    required this.isPrintCargoLabel,
    required this.isCanceled,
    required this.products,
    required this.shippingAddress,
    required this.billingAddress,
    required this.agreement,
  });

  factory OrderDetailData.fromJson(Map<String, dynamic> json) {
    return OrderDetailData(
      orderID: json['orderID'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      orderAmount: json['orderAmount'] ?? '',
      orderDiscount: json['orderDiscount'] ?? '',
      orderDescription: json['orderDescription'] ?? '',
      orderStatus: json['orderStatus'] ?? 0,
      orderStatusName: json['orderStatusName'] ?? '',
      paymentType: json['paymentType'] ?? '',
      orderDate: json['orderDate'] ?? '',
      deliveryDate: json['deliveryDate'] ?? '',
      invoice: json['invoice'] ?? '',
      isConfirmable: json['isConfirmable'] ?? false,
      isCancelable: json['isCancelable'] ?? false,
      isCreateLabel: json['isCreateLabel'] ?? false,
      isTrackingCargo: json['isTrackingCargo'] ?? false,
      isMarkAllAsShipped: json['isMarkAllAsShipped'] ?? false,
      isPrintCargoLabel: json['isPrintCargoLabel'] ?? false,
      isCanceled: json['isCanceled'] ?? false,
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => OrderProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      shippingAddress: json['shippingAddress'] != null
          ? OrderAddress.fromJson(json['shippingAddress'])
          : OrderAddress.empty(),
      billingAddress: json['billingAddress'] != null
          ? OrderAddress.fromJson(json['billingAddress'])
          : OrderAddress.empty(),
      agreement: json['agreement'] ?? '',
    );
  }
}

/// Sipariş ürünü modeli
class OrderProduct {
  final int opID;
  final int productID;
  final String productName;
  final String productImage;
  final String variants;
  final String varControl;
  final int status;
  final int statusID;
  final String statusText;
  final String statusName;
  final int quantity;
  final int cancelQuantity;
  final int currentQuantity;
  final int cargoID;
  final String cargoCompany;
  final String trackingNumber;
  final String trackingURL;
  final bool isConfirmable;
  final bool isAddCargoable;
  final bool isDelivered;
  final String productPrice;
  final String totalPrice;
  final String cargoAmount;
  final String notes;
  final String cancelDate;
  final bool canceled;
  final int cancelType;
  final String cancelDesc;
  final List<int> availableQuantities;

  OrderProduct({
    required this.opID,
    required this.productID,
    required this.productName,
    required this.productImage,
    required this.variants,
    required this.varControl,
    required this.status,
    required this.statusID,
    required this.statusText,
    required this.statusName,
    required this.quantity,
    required this.cancelQuantity,
    required this.currentQuantity,
    required this.cargoID,
    required this.cargoCompany,
    required this.trackingNumber,
    required this.trackingURL,
    required this.isConfirmable,
    required this.isAddCargoable,
    required this.isDelivered,
    required this.productPrice,
    required this.totalPrice,
    required this.cargoAmount,
    required this.notes,
    required this.cancelDate,
    required this.canceled,
    required this.cancelType,
    required this.cancelDesc,
    required this.availableQuantities,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      opID: json['opID'] ?? 0,
      productID: json['productID'] ?? 0,
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      variants: json['variants'] ?? '',
      varControl: json['varControl'] ?? '',
      status: json['status'] ?? 0,
      statusID: json['statusID'] ?? 0,
      statusText: json['statusText'] ?? '',
      statusName: json['statusName'] ?? '',
      quantity: json['quantity'] ?? 0,
      cancelQuantity: json['cancelQuantity'] ?? 0,
      currentQuantity: json['currentQuantity'] ?? 0,
      cargoID: json['cargoID'] ?? 0,
      cargoCompany: json['cargoCompany'] ?? '',
      trackingNumber: json['trackingNumber'] ?? '',
      trackingURL: json['trackingURL'] ?? '',
      isConfirmable: json['isConfirmable'] ?? false,
      isAddCargoable: json['isAddCargoable'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
      productPrice: json['productPrice'] ?? '',
      totalPrice: json['totalPrice'] ?? '',
      cargoAmount: json['cargoAmount'] ?? '',
      notes: json['notes'] ?? '',
      cancelDate: json['cancelDate'] ?? '',
      canceled: json['canceled'] ?? false,
      cancelType: json['cancelType'] ?? 0,
      cancelDesc: json['cancelDesc'] ?? '',
      availableQuantities:
          (json['availableQuantities'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  /// Ürün durumuna göre renk döndürür
  ProductStatusColor get productStatusColor {
    if (canceled) return ProductStatusColor.canceled;
    switch (statusID) {
      case 1:
        return ProductStatusColor.pending;
      case 2:
        return ProductStatusColor.processing;
      case 3:
        return ProductStatusColor.shipped;
      case 4:
        return ProductStatusColor.delivered;
      case 5:
        return ProductStatusColor.canceled;
      default:
        return ProductStatusColor.pending;
    }
  }
}

/// Adres modeli
class OrderAddress {
  final String addressName;
  final String addressType;
  final String addressCity;
  final String addressDistrict;
  final String addressNeighbourhood;
  final String address;
  final String invoiceAddress;
  final String identityNumber;
  final String realCompanyName;
  final String taxNumber;
  final String taxAdministration;

  OrderAddress({
    required this.addressName,
    required this.addressType,
    required this.addressCity,
    required this.addressDistrict,
    required this.addressNeighbourhood,
    required this.address,
    required this.invoiceAddress,
    required this.identityNumber,
    required this.realCompanyName,
    required this.taxNumber,
    required this.taxAdministration,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      addressName: json['addressName'] ?? '',
      addressType: json['addressType'] ?? '',
      addressCity: json['addressCity'] ?? '',
      addressDistrict: json['addressDistrict'] ?? '',
      addressNeighbourhood: json['addressNeighbourhood'] ?? '',
      address: json['address'] ?? '',
      invoiceAddress: json['invoiceAddress'] ?? '',
      identityNumber: json['identityNumber'] ?? '',
      realCompanyName: json['realCompanyName'] ?? '',
      taxNumber: json['taxNumber'] ?? '',
      taxAdministration: json['taxAdministration'] ?? '',
    );
  }

  factory OrderAddress.empty() {
    return OrderAddress(
      addressName: '',
      addressType: '',
      addressCity: '',
      addressDistrict: '',
      addressNeighbourhood: '',
      address: '',
      invoiceAddress: '',
      identityNumber: '',
      realCompanyName: '',
      taxNumber: '',
      taxAdministration: '',
    );
  }

  /// Tam adres stringi
  String get fullAddress {
    return '$address / $addressNeighbourhood / $addressDistrict / $addressCity';
  }

  /// Kurumsal mı kontrolü
  bool get isCorporate => addressType.toLowerCase() == 'kurumsal';
}

/// Sipariş durumu renkleri
enum OrderDetailStatusColor {
  pending(0xFFFFA726), // Orange
  processing(0xFF42A5F5), // Blue
  shipped(0xFF7E57C2), // Purple
  delivered(0xFF66BB6A), // Green
  canceled(0xFFEF5350); // Red

  final int colorValue;
  const OrderDetailStatusColor(this.colorValue);
}

/// Ürün durumu renkleri
enum ProductStatusColor {
  pending(0xFFFFA726), // Orange
  processing(0xFF42A5F5), // Blue
  shipped(0xFF7E57C2), // Purple
  delivered(0xFF66BB6A), // Green
  canceled(0xFFEF5350); // Red

  final int colorValue;
  const ProductStatusColor(this.colorValue);
}

/// Sipariş onaylama API response modeli
class OrderConfirmResponseModel {
  final bool error;
  final bool success;
  final String? successMessage;
  final OrderConfirmData? data;
  final String? code200;

  OrderConfirmResponseModel({
    required this.error,
    required this.success,
    this.successMessage,
    this.data,
    this.code200,
  });

  factory OrderConfirmResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderConfirmResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      successMessage: json['success_message'],
      data: json['data'] != null
          ? OrderConfirmData.fromJson(json['data'])
          : null,
      code200: json['200'],
    );
  }
}

/// Sipariş onaylama verisi
class OrderConfirmData {
  final int orderID;
  final int cargoID;
  final String trackingNo;
  final int orderStatusID;
  final String orderStatus;

  OrderConfirmData({
    required this.orderID,
    required this.cargoID,
    required this.trackingNo,
    required this.orderStatusID,
    required this.orderStatus,
  });

  factory OrderConfirmData.fromJson(Map<String, dynamic> json) {
    return OrderConfirmData(
      orderID: json['orderID'] ?? 0,
      cargoID: json['cargoID'] ?? 0,
      trackingNo: json['trackingNo'] ?? '',
      orderStatusID: json['orderStatusID'] ?? 0,
      orderStatus: json['orderStatus'] ?? '',
    );
  }
}

/// İptal edilecek ürün modeli
class CancelProduct {
  final int proID;
  final int quantity;
  final int cancelType;
  final String cancelDesc;

  CancelProduct({
    required this.proID,
    required this.quantity,
    required this.cancelType,
    required this.cancelDesc,
  });

  Map<String, dynamic> toJson() {
    return {
      'proID': proID,
      'quantity': quantity,
      'cancelType': cancelType,
      'cancelDesc': cancelDesc,
    };
  }
}

/// Sipariş iptal API response modeli
class OrderCancelResponseModel {
  final bool error;
  final bool success;
  final String? successMessage;
  final OrderCancelData? data;
  final String? code200;

  OrderCancelResponseModel({
    required this.error,
    required this.success,
    this.successMessage,
    this.data,
    this.code200,
  });

  factory OrderCancelResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderCancelResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      successMessage: json['success_message'],
      data: json['data'] != null
          ? OrderCancelData.fromJson(json['data'])
          : null,
      code200: json['200'],
    );
  }
}

/// Sipariş iptal verisi
class OrderCancelData {
  final int orderID;
  final int storeID;
  final String orderCode;
  final int canceledCount;
  final String orderStatus;

  OrderCancelData({
    required this.orderID,
    required this.storeID,
    required this.orderCode,
    required this.canceledCount,
    required this.orderStatus,
  });

  factory OrderCancelData.fromJson(Map<String, dynamic> json) {
    return OrderCancelData(
      orderID: json['orderID'] ?? 0,
      storeID: json['storeID'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      canceledCount: json['canceledCount'] ?? 0,
      orderStatus: json['orderStatus'] ?? '',
    );
  }
}

/// Sipariş iptal nedenleri API response modeli
class OrderCancelTypeResponseModel {
  final bool error;
  final bool success;
  final List<OrderCancelType>? data;
  final String? code200;

  OrderCancelTypeResponseModel({
    required this.error,
    required this.success,
    this.data,
    this.code200,
  });

  factory OrderCancelTypeResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderCancelTypeResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => OrderCancelType.fromJson(e as Map<String, dynamic>))
          .toList(),
      code200: json['200'],
    );
  }
}

/// Sipariş iptal nedeni modeli
class OrderCancelType {
  final int typeID;
  final String typeName;

  OrderCancelType({
    required this.typeID,
    required this.typeName,
  });

  factory OrderCancelType.fromJson(Map<String, dynamic> json) {
    return OrderCancelType(
      typeID: json['typeID'] ?? 0,
      typeName: json['typeName'] ?? '',
    );
  }
}

/// Etiket oluşturma API response modeli
class CreateLabelResponseModel {
  final bool error;
  final bool success;
  final String? successMessage;
  final CreateLabelData? data;
  final String? code200;

  CreateLabelResponseModel({
    required this.error,
    required this.success,
    this.successMessage,
    this.data,
    this.code200,
  });

  factory CreateLabelResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateLabelResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      successMessage: json['success_message'],
      data: json['data'] != null
          ? CreateLabelData.fromJson(json['data'])
          : null,
      code200: json['200'],
    );
  }
}

/// Etiket oluşturma verisi
class CreateLabelData {
  final int orderID;
  final int storeID;
  final String orderCode;
  final String trackingNo;
  final String? labelData;
  final String labelUrl;

  CreateLabelData({
    required this.orderID,
    required this.storeID,
    required this.orderCode,
    required this.trackingNo,
    this.labelData,
    required this.labelUrl,
  });

  factory CreateLabelData.fromJson(Map<String, dynamic> json) {
    return CreateLabelData(
      orderID: json['orderID'] ?? 0,
      storeID: json['storeID'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      trackingNo: json['trackingNo'] ?? '',
      labelData: json['labelData'],
      labelUrl: json['labelUrl'] ?? '',
    );
  }
}

/// Kargo ekleme API response modeli
class AddCargoResponseModel {
  final bool error;
  final bool success;
  final String? successMessage;
  final AddCargoData? data;
  final String? code200;

  AddCargoResponseModel({
    required this.error,
    required this.success,
    this.successMessage,
    this.data,
    this.code200,
  });

  factory AddCargoResponseModel.fromJson(Map<String, dynamic> json) {
    return AddCargoResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      successMessage: json['success_message'],
      data: json['data'] != null
          ? AddCargoData.fromJson(json['data'])
          : null,
      code200: json['200'],
    );
  }
}

/// Kargo ekleme verisi
class AddCargoData {
  final int orderID;
  final int cargoID;
  final String trackingNo;
  final int orderStatusID;
  final String orderStatus;

  AddCargoData({
    required this.orderID,
    required this.cargoID,
    required this.trackingNo,
    required this.orderStatusID,
    required this.orderStatus,
  });

  factory AddCargoData.fromJson(Map<String, dynamic> json) {
    return AddCargoData(
      orderID: json['orderID'] ?? 0,
      cargoID: json['cargoID'] ?? 0,
      trackingNo: json['trackingNo'] ?? '',
      orderStatusID: json['orderStatusID'] ?? 0,
      orderStatus: json['orderStatus'] ?? '',
    );
  }
}
