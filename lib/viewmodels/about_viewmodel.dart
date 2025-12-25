import 'package:flutter/material.dart';
import '../models/about/left_panel_settings.dart';
import '../services/about_service.dart';

class AboutViewModel extends ChangeNotifier {
  final AboutService _aboutService = AboutService();

  LeftPanelSettings? _leftPanelSettings;
  bool _isLoading = false;
  String? _error;

  LeftPanelSettings? get leftPanelSettings => _leftPanelSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Hakkında sayfası ayarlarını yükler
  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final settings = await _aboutService.getLeftPanelSettings();
      
      if (settings != null) {
        _leftPanelSettings = settings;
        _error = null;
      } else {
        _error = 'Ayarlar yüklenemedi';
      }
    } catch (e) {
      _error = 'Bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
