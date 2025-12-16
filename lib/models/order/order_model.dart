class OrderListResponseModel {
  final bool error;
  final bool success;
  final OrderListData? data;
  final String? code200;

  OrderListResponseModel({
    required this.error,
    required this.success,
    this.data,
    this.code200,
  });

  factory OrderListResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderListResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? OrderListData.fromJson(json['data']) : null,
      code200: json['200'],
    );
  }
}

class OrderListData {
  final List<Order> orders;
  final String emptyMessage;

  OrderListData({
    required this.orders,
    required this.emptyMessage,
  });

  factory OrderListData.fromJson(Map<String, dynamic> json) {
    return OrderListData(
      orders: (json['orders'] as List<dynamic>?)
              ?.map((e) => Order.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      emptyMessage: json['emptyMessage'] ?? '',
    );
  }
}

class Order {
  final int orderID;
  final String orderCode;
  final String orderAmount;
  final String orderDiscount;
  final int orderStatus;
  final String orderStatusTitle;
  final String orderPayment;
  final String orderDate;
  final String deliveryDate;
  final bool isCanceled;

  Order({
    required this.orderID,
    required this.orderCode,
    required this.orderAmount,
    required this.orderDiscount,
    required this.orderStatus,
    required this.orderStatusTitle,
    required this.orderPayment,
    required this.orderDate,
    required this.deliveryDate,
    required this.isCanceled,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderID: json['orderID'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      orderAmount: json['orderAmount'] ?? '',
      orderDiscount: json['orderDiscount'] ?? '',
      orderStatus: json['orderStatus'] ?? 0,
      orderStatusTitle: json['orderStatusTitle'] ?? '',
      orderPayment: json['orderPayment'] ?? '',
      orderDate: json['orderDate'] ?? '',
      deliveryDate: json['deliveryDate'] ?? '',
      isCanceled: json['isCanceled'] ?? false,
    );
  }

  /// Sipariş durumuna göre renk döndürür
  OrderStatusColor get statusColor {
    switch (orderStatus) {
      case 1:
        return OrderStatusColor.pending; // Beklemede
      case 2:
        return OrderStatusColor.processing; // İşleme Alındı
      case 3:
        return OrderStatusColor.shipped; // Kargoya Verildi
      case 4:
        return OrderStatusColor.delivered; // Teslim Edildi
      case 5:
        return OrderStatusColor.canceled; // İptal Edildi
      default:
        return OrderStatusColor.pending;
    }
  }
}

enum OrderStatusColor {
  pending(0xFFFFA726), // Orange
  processing(0xFF42A5F5), // Blue
  shipped(0xFF7E57C2), // Purple
  delivered(0xFF66BB6A), // Green
  canceled(0xFFEF5350); // Red

  final int colorValue;
  const OrderStatusColor(this.colorValue);
}
