import 'package:flutter/material.dart';
import '../models/auth/update_password_model.dart';
import '../services/users_service.dart';

class PasswordViewModel extends ChangeNotifier {
  final UsersService _usersService = UsersService();

  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Form fields
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  String get currentPassword => _currentPassword;
  String get newPassword => _newPassword;
  String get confirmPassword => _confirmPassword;

  void setCurrentPassword(String value) {
    _currentPassword = value;
    notifyListeners();
  }

  void setNewPassword(String value) {
    _newPassword = value;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }

  void resetState() {
    _isLoading = false;
    _isUpdating = false;
    _errorMessage = null;
    _successMessage = null;
    _currentPassword = '';
    _newPassword = '';
    _confirmPassword = '';
    // initState içinde çağrılabilmesi için notifyListeners() çağırmıyoruz
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  bool validateForm() {
    if (_currentPassword.isEmpty) {
      _errorMessage = 'Mevcut şifre boş olamaz';
      notifyListeners();
      return false;
    }

    if (_newPassword.isEmpty) {
      _errorMessage = 'Yeni şifre boş olamaz';
      notifyListeners();
      return false;
    }

    if (_newPassword.length < 6) {
      _errorMessage = 'Yeni şifre en az 6 karakter olmalıdır';
      notifyListeners();
      return false;
    }

    if (_confirmPassword.isEmpty) {
      _errorMessage = 'Şifre tekrarı boş olamaz';
      notifyListeners();
      return false;
    }

    if (_newPassword != _confirmPassword) {
      _errorMessage = 'Yeni şifre ve tekrarı eşleşmiyor';
      notifyListeners();
      return false;
    }

    if (_currentPassword == _newPassword) {
      _errorMessage = 'Yeni şifre mevcut şifre ile aynı olamaz';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    return true;
  }

  Future<bool> updatePassword(String token) async {
    debugPrint('🔐 [PASSWORD_VIEWMODEL] Şifre değiştirme başlatılıyor...');
    
    _isUpdating = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final request = UpdatePasswordRequestModel(
        userToken: token,
        currentPassword: _currentPassword,
        password: _newPassword,
        passwordAgain: _confirmPassword,
      );

      debugPrint('🔐 [PASSWORD_VIEWMODEL] Request hazırlandı: ${request.toJson()}');

      final response = await _usersService.updatePassword(request);

      debugPrint('🔐 [PASSWORD_VIEWMODEL] Response alındı:');
      debugPrint('   success: ${response.success}');
      debugPrint('   error: ${response.error}');
      debugPrint('   message: ${response.message}');
      debugPrint('   code200: ${response.code200}');

      _isUpdating = false;

      if (response.success && response.code200) {
        _successMessage = response.message ?? 'Şifreniz başarıyla değiştirildi';
        debugPrint('✅ [PASSWORD_VIEWMODEL] Şifre başarıyla değiştirildi');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? response.errorMessage ?? 'Şifre değiştirme başarısız';
        debugPrint('❌ [PASSWORD_VIEWMODEL] Şifre değiştirme başarısız: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ [PASSWORD_VIEWMODEL] HATA: $e');
      _isUpdating = false;
      _errorMessage = 'Bir hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }
}
