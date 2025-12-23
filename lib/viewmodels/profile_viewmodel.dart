import 'package:flutter/foundation.dart';
import 'package:besliyorum_satici/models/home/home_model.dart';
import '../services/users_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final UsersService _usersService = UsersService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HomeData? _userData;
  HomeData? get userData => _userData;

  Future<void> getUser(int userId, String userToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _usersService.getUserAccount(userId, userToken);

      if (response.success && response.data != null) {
        _userData = response.data;
      } else {
        _errorMessage = 'Kullanıcı bilgileri yüklenemedi';
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

  void clearState() {
    _errorMessage = null;
    _isLoading = false;
    _userData = null;
    notifyListeners();
  }

  void resetState() {
    _errorMessage = null;
    _isLoading = false;
    _userData = null;
  }
}
