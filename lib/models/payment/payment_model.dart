/// Ödeme listesi API yanıt modeli
class PaymentListResponseModel {
  final bool error;
  final bool success;
  final PaymentListData? data;
  final String? code200;

  PaymentListResponseModel({
    required this.error,
    required this.success,
    this.data,
    this.code200,
  });

  factory PaymentListResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentListResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? PaymentListData.fromJson(json['data']) : null,
      code200: json['200'],
    );
  }
}

/// Ödeme listesi veri modeli
class PaymentListData {
  final PaymentGroup pastPayments;
  final PaymentGroup futurePayments;

  PaymentListData({
    required this.pastPayments,
    required this.futurePayments,
  });

  factory PaymentListData.fromJson(Map<String, dynamic> json) {
    return PaymentListData(
      pastPayments: PaymentGroup.fromJson(json['pastPayments'] ?? {}),
      futurePayments: PaymentGroup.fromJson(json['futurePayments'] ?? {}),
    );
  }
}

/// Ödeme grubu modeli (geçmiş veya gelecek ödemeler)
class PaymentGroup {
  final String totalAmount;
  final int totalItems;
  final List<Payment> payments;

  PaymentGroup({
    required this.totalAmount,
    required this.totalItems,
    required this.payments,
  });

  factory PaymentGroup.fromJson(Map<String, dynamic> json) {
    return PaymentGroup(
      totalAmount: json['totalAmount'] ?? '0,00 TL',
      totalItems: json['totalItems'] ?? 0,
      payments: (json['payments'] as List<dynamic>?)
              ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Tekil ödeme modeli
class Payment {
  final int paymentID;
  final int orderID;
  final String payDate;
  final String payAmount;
  final String commissionRate;
  final bool isPaid;

  Payment({
    required this.paymentID,
    required this.orderID,
    required this.payDate,
    required this.payAmount,
    required this.commissionRate,
    required this.isPaid,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentID: json['paymentID'] ?? 0,
      orderID: json['orderID'] ?? 0,
      payDate: json['payDate'] ?? '',
      payAmount: json['payAmount'] ?? '',
      commissionRate: json['commissionRate'] ?? '',
      isPaid: json['isPaid'] ?? false,
    );
  }
}
