import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../core/constants/app_constants.dart';

class ApiService {
  final String _baseUrl = AppConstants.apiUrl;
  final Logger _logger = Logger();

  Map<String, String> _getHeaders() {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('${AppConstants.basicAuthUsername}:${AppConstants.basicAuthPassword}'))}';
    return {'Authorization': basicAuth, 'Content-Type': 'application/json'};
  }

  Future<http.Response> post(String endpoint, {dynamic body}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = _getHeaders();
    final jsonBody = jsonEncode(body);

    _logger.i('POST Request: $url\nHeaders: $headers\nBody: $jsonBody');

    try {
      final response = await http.post(url, headers: headers, body: jsonBody);

      _logger.i(
        'POST Response: $url\nStatus: ${response.statusCode}\nBody: ${response.body}',
      );

      // Handle 417 as a valid response type for logic
      if (response.statusCode == 417 || response.statusCode == 200) {
        return response;
      } else {
        throw Exception(
          'Network Error: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      _logger.e('POST Error: $url', error: e);
      rethrow;
    }
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = _getHeaders();

    _logger.i('GET Request: $url\nHeaders: $headers');

    try {
      final response = await http.get(url, headers: headers);

      _logger.i(
        'GET Response: $url\nStatus: ${response.statusCode}\nBody: ${response.body}',
      );

      if (response.statusCode == 417 ||
          response.statusCode == 410 ||
          response.statusCode == 200) {
        return response;
      } else {
        throw Exception(
          'Network Error: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      _logger.e('GET Error: $url', error: e);
      rethrow;
    }
  }

  Future<http.Response> put(String endpoint, {dynamic body}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = _getHeaders();
    final jsonBody = jsonEncode(body);

    _logger.i('PUT Request: $url\nHeaders: $headers\nBody: $jsonBody');

    try {
      final response = await http.put(url, headers: headers, body: jsonBody);

      _logger.i(
        'PUT Response: $url\nStatus: ${response.statusCode}\nBody: ${response.body}',
      );

      if (response.statusCode == 417 || response.statusCode == 200) {
        return response;
      } else {
        throw Exception(
          'Network Error: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      _logger.e('PUT Error: $url', error: e);
      rethrow;
    }
  }
}
