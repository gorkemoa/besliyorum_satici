import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/about/left_panel_settings.dart';

class AboutService {
  final Logger _logger = Logger();
  static const String _settingsUrl =
      'https://besliyorum.b-cdn.net/bes_homepage_settings.1.0.9.json';

  /// Hakkında sayfası ayarlarını uzak sunucudan çeker
  Future<LeftPanelSettings?> getLeftPanelSettings() async {
    try {
      final url = Uri.parse(_settingsUrl);
      _logger.i('Fetching About Settings: $url');

      final response = await http.get(url);

      _logger.i(
        'About Settings Response: Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        // JSON response bir array, "left_panel_settings" olan ilk elemanı bul
        if (jsonData is List && jsonData.isNotEmpty) {
          final leftPanelData = jsonData.firstWhere(
            (item) => item['code'] == 'left_panel_settings',
            orElse: () => null,
          );
          if (leftPanelData != null) {
            return LeftPanelSettings.fromJson(leftPanelData);
          }
        }
        return null;
      } else {
        _logger.e(
          'Failed to load settings: ${response.statusCode} ${response.reasonPhrase}',
        );
        return null;
      }
    } catch (e) {
      _logger.e('Error fetching About Settings', error: e);
      return null;
    }
  }
}
