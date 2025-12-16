import 'package:flutter/foundation.dart';
import 'package:besliyorum_satici/models/home/home_model.dart';
import '../services/users_service.dart';

class HomeViewModel extends ChangeNotifier {
  final UsersService _usersService = UsersService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HomeData? _homeData;
  HomeData? get homeData => _homeData;

  Future<void> getUserAccount(int userId, String userToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _usersService.getUserAccount(userId, userToken);

      if (response.success && response.data != null) {
        _homeData = response.data;
      } else {
        _errorMessage = 'Failed to load user data';
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        _errorMessage = '403_LOGOUT'; // Special error code to handle in UI
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// State'i temizler ve UI'ı bilgilendirir
  void clearState() {
    _errorMessage = null;
    _isLoading = false;
    _homeData = null;
    notifyListeners();
  }

  /// State'i sessizce temizler (initState için - notifyListeners çağırmaz)
  void resetState() {
    _errorMessage = null;
    _isLoading = false;
    _homeData = null;
  }
}
