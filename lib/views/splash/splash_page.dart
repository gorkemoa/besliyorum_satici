import 'package:flutter/material.dart';
import 'package:besliyorum_satici/core/theme/app_theme.dart';
import 'package:besliyorum_satici/views/auth/login_page.dart';
import 'package:provider/provider.dart';
import '../../core/services/local_storage_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/firebase_messaging_service.dart';
import '../main_navigation.dart';

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

    if (!mounted) return;

    final localStorage = LocalStorageService();
    final token = await localStorage.getToken();

    if (mounted) {
      if (token != null && token.isNotEmpty) {
        final userId = await localStorage.getUserId();
        if (userId != null) {
          final authViewModel = Provider.of<AuthViewModel>(
            context,
            listen: false,
          );
          authViewModel.restoreSession(token, userId);

          // Firebase topic'e abone ol (user ID ile)
          await FirebaseMessagingService.subscribeToUserTopic(
            userId.toString(),
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
          return;
        }
      }

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
