import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                  const TextField(
                    // Using standard TextField for now, can be customized further
                    decoration: InputDecoration(hintText: 'Kullanıcı Adınız'),
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(hintText: 'Şifreniz'),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement login logic
                    },
                    child: const Text(
                      'GİRİŞ YAP',
                      style: TextStyle(letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Forgot Password
                  Center(
                    child: GestureDetector(
                      onTap: () {},
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
                        onTap: () {},
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
