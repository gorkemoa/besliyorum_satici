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

  /// Sipariş durumuna göre renk döndürür
  OrderDetailStatusColor get statusColor {
    if (isCanceled) return OrderDetailStatusColor.canceled;
    switch (orderStatus) {
      case 1:
        return OrderDetailStatusColor.pending;
      case 2:
        return OrderDetailStatusColor.processing;
      case 3:
        return OrderDetailStatusColor.shipped;
      case 4:
        return OrderDetailStatusColor.delivered;
      case 5:
        return OrderDetailStatusColor.canceled;
      default:
        return OrderDetailStatusColor.pending;
    }
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
  final bool isCargo;
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
    required this.isCargo,
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
      isCargo: json['isCargo'] ?? false,
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
