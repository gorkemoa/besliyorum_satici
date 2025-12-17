import 'package:flutter/foundation.dart';
import 'package:besliyorum_satici/models/order/order_model.dart';
import 'package:besliyorum_satici/models/order/order_detail_model.dart';
import 'package:besliyorum_satici/models/order/order_status_model.dart';
import '../services/order_service.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  String _emptyMessage = '';
  String get emptyMessage => _emptyMessage;

  // Order Detail State
  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;

  String? _detailErrorMessage;
  String? get detailErrorMessage => _detailErrorMessage;

  OrderDetailData? _orderDetail;
  OrderDetailData? get orderDetail => _orderDetail;

  // Order Statuses State
  List<OrderStatus> _orderStatuses = [];
  List<OrderStatus> get orderStatuses => _orderStatuses;

  bool _isStatusesLoading = false;
  bool get isStatusesLoading => _isStatusesLoading;

  // Filtre değerleri
  String? _startDate;
  String? get startDate => _startDate;

  String? _endDate;
  String? get endDate => _endDate;

  String? _orderCode;
  String? get orderCode => _orderCode;

  int? _orderStatus;
  int? get orderStatus => _orderStatus;

  bool get hasActiveFilters =>
      (_startDate != null && _startDate!.isNotEmpty) ||
      (_endDate != null && _endDate!.isNotEmpty) ||
      (_orderCode != null && _orderCode!.isNotEmpty) ||
      _orderStatus != null;

  /// Filtre değerlerini günceller
  void setFilters({
    String? startDate,
    String? endDate,
    String? orderCode,
    int? orderStatus,
  }) {
    _startDate = startDate;
    _endDate = endDate;
    _orderCode = orderCode;
    _orderStatus = orderStatus;
    notifyListeners();
  }

  /// Filtreleri temizler
  void clearFilters() {
    _startDate = null;
    _endDate = null;
    _orderCode = null;
    _orderStatus = null;
    notifyListeners();
  }

  /// Kullanıcının siparişlerini yükler
  Future<void> getUserOrders(String userToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _orderService.getUserOrders(
        userToken,
        startDate: _startDate,
        endDate: _endDate,
        orderCode: _orderCode,
        orderStatus: _orderStatus,
      );

      if (response.success && response.data != null) {
        _orders = response.data!.orders;
        _emptyMessage = response.data!.emptyMessage;
      } else {
        _errorMessage = 'Siparişler yüklenemedi';
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

  /// Sipariş detayını yükler
  Future<void> getOrderDetail(String userToken, int orderID) async {
    _isDetailLoading = true;
    _detailErrorMessage = null;
    notifyListeners();

    try {
      final response = await _orderService.getOrderDetail(userToken, orderID);

      if (response.success && response.data != null) {
        _orderDetail = response.data;
      } else {
        _detailErrorMessage = 'Sipariş detayı yüklenemedi';
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        _detailErrorMessage = '403_LOGOUT';
      } else {
        _detailErrorMessage = e.toString();
      }
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  /// Sipariş detay state'ini temizler
  void clearOrderDetail() {
    _orderDetail = null;
    _detailErrorMessage = null;
    _isDetailLoading = false;
  }

  /// Sipariş durumlarını yükler
  Future<void> getOrderStatuses() async {
    // Zaten yüklenmişse tekrar yükleme
    if (_orderStatuses.isNotEmpty) return;

    _isStatusesLoading = true;
    notifyListeners();

    try {
      final response = await _orderService.getOrderStatuses();

      if (response.success && response.data != null) {
        _orderStatuses = response.data!;
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    } finally {
      _isStatusesLoading = false;
      notifyListeners();
    }
  }

  /// State'i temizler ve UI'ı bilgilendirir
  void clearState() {
    _errorMessage = null;
    _isLoading = false;
    _orders = [];
    _emptyMessage = '';
    _startDate = null;
    _endDate = null;
    _orderCode = null;
    _orderStatus = null;
    _orderDetail = null;
    _detailErrorMessage = null;
    _isDetailLoading = false;
    notifyListeners();
  }

  /// State'i sessizce temizler (initState için - notifyListeners çağırmaz)
  void resetState() {
    _errorMessage = null;
    _isLoading = false;
    _orders = [];
    _emptyMessage = '';
    _startDate = null;
    _endDate = null;
    _orderCode = null;
    _orderStatus = null;
    _orderDetail = null;
    _detailErrorMessage = null;
    _isDetailLoading = false;
    // _orderStatuses temizlenmez - cache'de kalır
  }

  /// Sipariş detay state'ini sessizce temizler (initState için)
  void resetDetailState() {
    _orderDetail = null;
    _detailErrorMessage = null;
    _isDetailLoading = false;
  }
}
