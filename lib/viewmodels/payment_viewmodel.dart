import 'package:flutter/foundation.dart';
import 'package:besliyorum_satici/models/payment/payment_model.dart';
import 'package:besliyorum_satici/models/payment/payment_detail_model.dart';
import '../services/payment_service.dart';

class PaymentViewModel extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PaymentListData? _paymentData;
  PaymentListData? get paymentData => _paymentData;

  PaymentDetail? _paymentDetail;
  PaymentDetail? get paymentDetail => _paymentDetail;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  String? _detailErrorMessage;
  String? get detailErrorMessage => _detailErrorMessage;

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
    _paymentDetail = null;
    _isLoadingDetail = false;
    _detailErrorMessage = null;
  }

  /// Ödeme detayını sıfırlar
  void resetDetailState() {
    _paymentDetail = null;
    _isLoadingDetail = false;
    _detailErrorMessage = null;
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

  /// Ödeme detayını yükler
  Future<void> getPaymentDetail(String userToken, int payID) async {
    _isLoadingDetail = true;
    _detailErrorMessage = null;
    _paymentDetail = null;
    notifyListeners();

    try {
      final response = await _paymentService.getPaymentDetail(userToken, payID);

      if (response.success && response.data != null) {
        _paymentDetail = response.data;
      } else {
        _detailErrorMessage = 'Ödeme detayı yüklenemedi';
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        _detailErrorMessage = '403_LOGOUT';
      } else if (e.toString().contains('417')) {
        _detailErrorMessage = e.toString();
      } else {
        _detailErrorMessage = 'Bir hata oluştu';
      }
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }
}
