import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:besliyorum_satici/models/home/home_model.dart';
import 'package:besliyorum_satici/models/auth/update_user_model.dart';
import '../services/users_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final UsersService _usersService = UsersService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  HomeData? _userData;
  HomeData? get userData => _userData;

  // Form alanları
  String _userFirstname = '';
  String _userLastname = '';
  String _userEmail = '';
  String _userBirthday = '';
  String _userPhone = '';
  String _userGender = 'Belirsiz';

  // Getters
  String get userFirstname => _userFirstname;
  String get userLastname => _userLastname;
  String get userEmail => _userEmail;
  String get userBirthday => _userBirthday;
  String get userPhone => _userPhone;
  String get userGender => _userGender;

  // Cinsiyet seçenekleri
  final List<String> genderOptions = ['Erkek', 'Kadın', 'Belirsiz'];

  void resetState() {
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    _isUpdating = false;
    _userData = null;
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> getUser(int userId, String userToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _usersService.getUserAccount(userId, userToken);

      if (response.success && response.data != null) {
        _userData = response.data;
        _initializeFormFields();
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

  void _initializeFormFields() {
    if (_userData != null) {
      // userFullname'i firstname ve lastname'e böl
      final nameParts = _userData!.userFullname.trim().split(' ');
      if (nameParts.length > 1) {
        _userFirstname = nameParts.first;
        _userLastname = nameParts.sublist(1).join(' ');
      } else {
        _userFirstname = _userData!.userFullname;
        _userLastname = '';
      }
      _userEmail = _userData!.userEmail;
      _userBirthday = _userData!.userBirthday;
      _userPhone = _userData!.userPhone;
      _userGender = _userData!.userGender.isNotEmpty ? _userData!.userGender : 'Belirsiz';
    }
  }

  // Setters
  void setUserFirstname(String value) {
    _userFirstname = value;
    notifyListeners();
  }

  void setUserLastname(String value) {
    _userLastname = value;
    notifyListeners();
  }

  void setUserEmail(String value) {
    _userEmail = value;
    notifyListeners();
  }

  void setUserBirthday(String value) {
    _userBirthday = value;
    notifyListeners();
  }

  void setUserPhone(String value) {
    _userPhone = value;
    notifyListeners();
  }

  void setUserGender(String value) {
    _userGender = value;
    notifyListeners();
  }

  Future<bool> updateUser(String userToken) async {
    _isUpdating = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final request = UpdateUserRequestModel(
        userToken: userToken,
        userFirstname: _userFirstname,
        userLastname: _userLastname,
        userEmail: _userEmail,
        userPhone: _userPhone,
        userBirthday: _userBirthday,
        userGender: _userGender,
        profilePhoto: _userData?.profilePhoto ?? '',
      );

      debugPrint('📤 [SETTINGS_VM] Request Body:');
      debugPrint('   userToken: $userToken');
      debugPrint('   userFirstname: $_userFirstname');
      debugPrint('   userLastname: $_userLastname');
      debugPrint('   userEmail: $_userEmail');
      debugPrint('   userPhone: $_userPhone');
      debugPrint('   userBirthday: $_userBirthday');
      debugPrint('   userGender: $_userGender');
      debugPrint('   profilePhoto: ${_userData?.profilePhoto ?? ""}');

      final response = await _usersService.updateUser(request);

      debugPrint('📥 [SETTINGS_VM] Response:');
      debugPrint('   success: ${response.success}');
      debugPrint('   error: ${response.error}');
      debugPrint('   code200: ${response.code200}');
      debugPrint('   errorMessage: ${response.errorMessage}');

      if (response.success && !response.error) {
        _successMessage = 'Bilgileriniz başarıyla güncellendi';
        debugPrint('✅ [SETTINGS_VM] Güncelleme başarılı!');
        return true;
      } else {
        _errorMessage = response.errorMessage ?? 'Güncelleme başarısız oldu';
        debugPrint('❌ [SETTINGS_VM] Güncelleme başarısız: $_errorMessage');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [SETTINGS_VM] Exception: $e');
      if (e.toString().contains('403')) {
        _errorMessage = '403_LOGOUT';
      } else {
        _errorMessage = 'Bir hata oluştu: ${e.toString()}';
      }
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  bool validateForm() {
    if (_userFirstname.trim().isEmpty) {
      _errorMessage = 'Ad alanı zorunludur';
      notifyListeners();
      return false;
    }
    if (_userLastname.trim().isEmpty) {
      _errorMessage = 'Soyad alanı zorunludur';
      notifyListeners();
      return false;
    }
    if (_userEmail.trim().isEmpty) {
      _errorMessage = 'E-posta alanı zorunludur';
      notifyListeners();
      return false;
    }
    if (_userPhone.trim().isEmpty) {
      _errorMessage = 'Telefon alanı zorunludur';
      notifyListeners();
      return false;
    }
    // E-posta formatı kontrolü
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_userEmail)) {
      _errorMessage = 'Geçerli bir e-posta adresi giriniz';
      notifyListeners();
      return false;
    }
    return true;
  }
}
