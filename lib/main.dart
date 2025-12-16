import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:besliyorum_satici/views/splash/splash_page.dart';
import 'package:besliyorum_satici/core/theme/app_theme.dart';
import 'package:besliyorum_satici/viewmodels/auth_viewmodel.dart';
import 'package:besliyorum_satici/viewmodels/home_viewmodel.dart';
import 'package:besliyorum_satici/viewmodels/order_viewmodel.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() {
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

      ],
      child: GestureDetector(
        onTap: () {
          // Herhangi bir yere dokunulduğunda klavyeyi kapat
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: MaterialApp(
          title: 'Besliyorum Satıcı',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashPage(),
                // 👇 BUNLAR ŞART
        locale: const Locale('tr', 'TR'),
        supportedLocales: const [
          Locale('tr', 'TR'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate, // 👈 AY OLAYINI BU ÇÖZER
        ]
        ),
      ),
    );
  }
}
