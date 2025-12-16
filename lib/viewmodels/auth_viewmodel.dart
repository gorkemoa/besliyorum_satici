import 'package:flutter/foundation.dart';
import 'package:besliyorum_satici/models/auth/login_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LoginResponseModel? _loginResponse;
  LoginResponseModel? get loginResponse => _loginResponse;

  Future<void> login(String userName, String userPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = LoginRequestModel(
        userName: userName,
        userPassword: userPassword,
      );

      _loginResponse = await _authService.login(request);

      if (_loginResponse != null) {
        if ((!_loginResponse!.success || _loginResponse!.error) &&
            _loginResponse!.errorMessage != null) {
          _errorMessage = _loginResponse!.errorMessage;
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void restoreSession(String token, int userId) {
    // Manually reconstruct partial login response or just hold variables
    _loginResponse = LoginResponseModel(
      error: false,
      success: true,
      data: LoginData(userID: userId, token: token),
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _loginResponse = null;
    notifyListeners();
  }

  Future<bool> checkLoginStatus() async {
    // Basic check - in a real app, verify token validity or simply existence
    // Since we don't have direct access to storage service here easily unless injected,
    // we can rely on data being populated if we had a dedicated `loadUser` method.
    // For now, let's assume we proceed to login if no data in memory.
    // Ideally, SplashPage should handle this check using LocalStorageService directly or via this VM.
    // Let's add a simple check using LocalStorageService if we import it or expose it from AuthService.
    // For simplicity given the scope, we will implement this in SplashPage or here if needed.
    return false;
  }
}
