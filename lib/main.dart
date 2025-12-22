import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:besliyorum_satici/views/splash/splash_page.dart';
import 'package:besliyorum_satici/core/theme/app_theme.dart';
import 'package:besliyorum_satici/viewmodels/auth_viewmodel.dart';
import 'package:besliyorum_satici/viewmodels/home_viewmodel.dart';
import 'package:besliyorum_satici/viewmodels/order_viewmodel.dart';
import 'package:besliyorum_satici/viewmodels/notification_viewmodel.dart';
import 'package:besliyorum_satici/viewmodels/register_viewmodel.dart';
import 'package:besliyorum_satici/viewmodels/product_viewmodel.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/firebase_messaging_service.dart';
import 'services/navigation_service.dart';

/// Global Navigator Key - Push bildirimlerinden navigasyon için
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📬 Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Firebase Messaging servisini başlat
  await FirebaseMessagingService.initialize();

  // Navigation Service'e navigator key'i ata
  NavigationService.navigatorKey = navigatorKey;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
      ],
      child: GestureDetector(
        onTap: () {
          // Herhangi bir yere dokunulduğunda klavyeyi kapat
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Besliyorum Satıcı',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashPage(),
          // 👇 BUNLAR ŞART
          locale: const Locale('tr', 'TR'),
          supportedLocales: const [Locale('tr', 'TR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate, // 👈 AY OLAYINI BU ÇÖZER
          ],
        ),
      ),
    );
  }
}
