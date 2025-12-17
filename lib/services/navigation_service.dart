import 'package:flutter/material.dart';
import 'package:besliyorum_satici/views/order/order_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// Navigation Service - Push bildirimi ve deep link navigasyonları için
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  /// Global Navigator Key - main.dart'tan set edilir
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Deep link navigasyonunu handle eder
  ///
  /// Desteklenen tipler:
  /// - order_sp_created: Sipariş detay sayfasına yönlendirir
  /// - return_sp_request: Sipariş detay sayfasına yönlendirir (iade talebi)
  ///
  /// typeId -1 ise ve url varsa, url'e yönlendirir
  void handleDeepLink({
    required String type,
    required int typeId,
    String? url,
    String? title,
  }) {
    debugPrint('🚀 NavigationService: type=$type, typeId=$typeId, url=$url');

    // typeId -1 ise ve url varsa, harici URL'e yönlendir
    if (typeId == -1 && url != null && url.isNotEmpty) {
      _launchUrl(url);
      return;
    }

    final context = navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('❌ NavigationService: Navigator context bulunamadı');
      return;
    }

    debugPrint('🚀 NavigationService: Navigating to $type with ID: $typeId');

    switch (type) {
      case 'order_sp_created':
      case 'return_sp_request':
        // Sipariş detay sayfasına yönlendir
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(orderID: typeId),
          ),
        );
        break;
      default:
        // Bilinmeyen tip ama url varsa, url'e yönlendir
        if (url != null && url.isNotEmpty) {
          _launchUrl(url);
        } else {
          debugPrint('⚠️ NavigationService: Bilinmeyen tip: $type');
        }
        break;
    }
  }

  /// Harici URL'i aç
  Future<void> _launchUrl(String url) async {
    debugPrint('🌐 NavigationService: Opening URL: $url');
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('❌ NavigationService: URL açılamadı: $url');
      }
    } catch (e) {
      debugPrint('❌ NavigationService: URL açılırken hata: $e');
    }
  }
}
