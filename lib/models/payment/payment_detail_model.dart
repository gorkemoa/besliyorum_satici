class PaymentDetailResponse {
  final bool error;
  final bool success;
  final PaymentDetail? data;

  PaymentDetailResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory PaymentDetailResponse.fromJson(Map<String, dynamic> json) {
    return PaymentDetailResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? PaymentDetail.fromJson(json['data']) : null,
    );
  }
}

class PaymentDetail {
  final int paymentID;
  final int orderID;
  final String payDate;
  final AmountDetail salesAmount;
  final AmountDetail cargoDeduction;
  final AmountDetail platformFee;
  final AmountDetail ecommerceWithholding;
  final AmountDetail commissionDeduction;
  final AmountDetail otherFees;
  final AmountDetail netAmount;
  final bool isPaid;

  PaymentDetail({
    required this.paymentID,
    required this.orderID,
    required this.payDate,
    required this.salesAmount,
    required this.cargoDeduction,
    required this.platformFee,
    required this.ecommerceWithholding,
    required this.commissionDeduction,
    required this.otherFees,
    required this.netAmount,
    required this.isPaid,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      paymentID: json['paymentID'] ?? 0,
      orderID: json['orderID'] ?? 0,
      payDate: json['payDate'] ?? '',
      salesAmount: AmountDetail.fromJson(json['salesAmount'] ?? {}),
      cargoDeduction: AmountDetail.fromJson(json['cargoDeduction'] ?? {}),
      platformFee: AmountDetail.fromJson(json['platformFee'] ?? {}),
      ecommerceWithholding: AmountDetail.fromJson(json['ecommerceWithholding'] ?? {}),
      commissionDeduction: AmountDetail.fromJson(json['commissionDeduction'] ?? {}),
      otherFees: AmountDetail.fromJson(json['otherFees'] ?? {}),
      netAmount: AmountDetail.fromJson(json['netAmount'] ?? {}),
      isPaid: json['isPaid'] ?? false,
    );
  }
}

class AmountDetail {
  final String amount;
  final String description;

  AmountDetail({
    required this.amount,
    required this.description,
  });

  factory AmountDetail.fromJson(Map<String, dynamic> json) {
    return AmountDetail(
      amount: json['amount'] ?? '0,00 TL',
      description: json['description'] ?? '',
    );
  }
}
