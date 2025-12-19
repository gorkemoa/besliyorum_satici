import 'package:flutter/material.dart';
import 'package:besliyorum_satici/core/components/app_dialog.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/firebase_messaging_service.dart';
import '../home/home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.38,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Image.asset(
                    'assets/Icons/bes-logo-beyaz-sloganli.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Satıcı Girişi',
                    textAlign: TextAlign.center,
                    style: textTheme.displayMedium?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Lütfen size iletilen kullanıcı adı ve şifre ile\ngiriş yapınız.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Username Input
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Kullanıcı Adınız',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Şifreniz'),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  // Login Button
                  Consumer<AuthViewModel>(
                    builder: (context, viewModel, child) {
                      return ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                final username = _usernameController.text;
                                final password = _passwordController.text;

                                await viewModel.login(username, password);

                                if (viewModel.errorMessage != null) {
                                  if (context.mounted) {
                                    AppDialog.show(
                                      context: context,
                                      title: 'Hata',
                                      content: viewModel.errorMessage!,
                                      type: AppDialogType.alert,
                                      confirmText: 'Tamam',
                                    );
                                  }
                                } else if (viewModel.loginResponse?.success ==
                                    true) {
                                  // Firebase topic'e abone ol (user ID ile)
                                  final userId =
                                      viewModel.loginResponse?.data?.userID;
                                  if (userId != null) {
                                    await FirebaseMessagingService.subscribeToUserTopic(
                                      userId.toString(),
                                    );
                                  }
                                  // Navigate to next screen or show success
                                  if (context.mounted) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => const HomePage(),
                                      ),
                                    );
                                  }
                                }
                              },
                        child: viewModel.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'GİRİŞ YAP',
                                style: TextStyle(letterSpacing: 1.5),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  // Forgot Password
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        AppDialog.show(
                          context: context,
                          title: 'Şifre Yenileme',
                          content:
                              'Şifre yenileme bağlantısı e-posta adresinize gönderilecektir.',
                          type: AppDialogType.info,
                          confirmText: 'Tamam',
                        );
                      },
                      child: Text(
                        'Şifrenizi mi unuttunuz?',
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFFF8A65), // Lighter orange
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFFFF8A65),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Satıcı değil misiniz? ',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Kaydol',
                          style: textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFFF8A65), // Lighter orange
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFFFF8A65),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
