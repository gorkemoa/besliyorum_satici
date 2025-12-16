import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Basic color estimation
    const Color primaryRed = Color(0xFFC62828); // Deep Red
    const Color titleColor = Color(0xFFE64A19); // Deep Orange

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.38,
              decoration: const BoxDecoration(
                color: primaryRed,
                borderRadius: BorderRadius.only(
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
                  const Text(
                    'Satıcı Girişi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Lütfen size iletilen kullanıcı adı ve şifre\nile giriş yapınız.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Username Input
                  TextField(
                    // Using standard TextField for now, can be customized further
                    decoration: InputDecoration(
                      hintText: 'Kullanıcı Adınız',
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Şifreniz',
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement login logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          5,
                        ), // Slightly rounded/rectangular as per image
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'GİRİŞ YAP',
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Forgot Password
                  Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Şifrenizi mi unuttunuz?',
                        style: TextStyle(
                          color: Color(0xFFFF8A65), // Lighter orange
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFFF8A65),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Satıcı değil misiniz? ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Kaydol',
                          style: TextStyle(
                            color: Color(0xFFFF8A65), // Lighter orange
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFFF8A65),
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
