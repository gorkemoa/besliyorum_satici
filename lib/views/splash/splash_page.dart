import 'package:flutter/material.dart';
import 'package:besliyorum_satici/core/theme/app_theme.dart';
import 'package:besliyorum_satici/views/auth/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(58.0),
          child: Image.asset(
            'assets/Icons/bes-logo-beyaz-sloganli.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
