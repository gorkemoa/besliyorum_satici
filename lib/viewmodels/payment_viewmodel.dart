import 'package:flutter/foundation.dart';
import 'package:besliyorum_satici/models/payment/payment_model.dart';
import '../services/payment_service.dart';

class PaymentViewModel extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PaymentListData? _paymentData;
  PaymentListData? get paymentData => _paymentData;

  // Geçmiş ödemeler
  List<Payment> get pastPayments => _paymentData?.pastPayments.payments ?? [];
  String get pastPaymentsTotalAmount => _paymentData?.pastPayments.totalAmount ?? '0,00 TL';
  int get pastPaymentsTotalItems => _paymentData?.pastPayments.totalItems ?? 0;

  // Gelecek ödemeler
  List<Payment> get futurePayments => _paymentData?.futurePayments.payments ?? [];
  String get futurePaymentsTotalAmount => _paymentData?.futurePayments.totalAmount ?? '0,00 TL';
  int get futurePaymentsTotalItems => _paymentData?.futurePayments.totalItems ?? 0;

  /// State'i sıfırlar
  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    _paymentData = null;
  }

  /// Kullanıcının ödemelerini yükler
  Future<void> getPayments(String userToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _paymentService.getPayments(userToken);

      if (response.success && response.data != null) {
        _paymentData = response.data;
      } else {
        _errorMessage = 'Ödemeler yüklenemedi';
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        _errorMessage = '403_LOGOUT';
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
