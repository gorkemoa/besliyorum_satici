class OrderStatusResponseModel {
  final bool error;
  final bool success;
  final List<OrderStatus>? data;

  OrderStatusResponseModel({
    required this.error,
    required this.success,
    this.data,
  });

  factory OrderStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusResponseModel(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => OrderStatus.fromJson(item))
              .toList()
          : null,
    );
  }
}

class OrderStatus {
  final int statusID;
  final String statusName;

  OrderStatus({
    required this.statusID,
    required this.statusName,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      statusID: json['statusID'] ?? 0,
      statusName: json['statusName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusID': statusID,
      'statusName': statusName,
    };
  }
}
