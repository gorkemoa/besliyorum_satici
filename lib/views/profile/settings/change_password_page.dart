import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/components/app_dialog.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/password_viewmodel.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    Provider.of<PasswordViewModel>(context, listen: false).resetState();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final passwordViewModel = Provider.of<PasswordViewModel>(context, listen: false);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Form değerlerini ViewModel'e aktar
    passwordViewModel.setCurrentPassword(_currentPasswordController.text);
    passwordViewModel.setNewPassword(_newPasswordController.text);
    passwordViewModel.setConfirmPassword(_confirmPasswordController.text);

    debugPrint('🔵 [CHANGE_PASSWORD] Form değerleri:');
    debugPrint('   Mevcut Şifre: ${_currentPasswordController.text.isNotEmpty ? "***" : "BOŞ"}');
    debugPrint('   Yeni Şifre: ${_newPasswordController.text.isNotEmpty ? "***" : "BOŞ"}');
    debugPrint('   Şifre Tekrar: ${_confirmPasswordController.text.isNotEmpty ? "***" : "BOŞ"}');

    if (!passwordViewModel.validateForm()) {
      debugPrint('❌ [CHANGE_PASSWORD] Form validasyonu başarısız!');
      AppDialog.show(
        context: context,
        title: 'Hata',
        content: passwordViewModel.errorMessage ?? 'Lütfen tüm alanları kontrol edin',
        type: AppDialogType.alert,
        confirmText: 'Tamam',
      );
      return;
    }

    final token = authViewModel.loginResponse?.data?.token;
    if (token == null) {
      debugPrint('❌ [CHANGE_PASSWORD] Token bulunamadı!');
      AppDialog.show(
        context: context,
        title: 'Hata',
        content: 'Oturum bilgisi bulunamadı',
        type: AppDialogType.alert,
        confirmText: 'Tamam',
      );
      return;
    }

    debugPrint('🔵 [CHANGE_PASSWORD] API çağrısı başlıyor...');
    final success = await passwordViewModel.updatePassword(token);
    debugPrint('🔵 [CHANGE_PASSWORD] API çağrısı tamamlandı. Başarılı: $success');

    if (mounted) {
      if (success) {
        AppDialog.show(
          context: context,
          title: 'Başarılı',
          content: passwordViewModel.successMessage ?? 'Şifreniz başarıyla değiştirildi',
          type: AppDialogType.info,
          confirmText: 'Tamam',
          onConfirm: () {
            Navigator.of(context).pop(); // Dialog'u kapat
            Navigator.of(context).pop(); // Sayfayı kapat
          },
        );
      } else {
        AppDialog.show(
          context: context,
          title: 'Hata',
          content: passwordViewModel.errorMessage ?? 'Şifre değiştirme başarısız',
          type: AppDialogType.alert,
          confirmText: 'Tamam',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Text(
          'Şifre Değiştir',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<PasswordViewModel>(
        builder: (context, passwordViewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bilgilendirme
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Güvenliğiniz için şifrenizi düzenli olarak değiştirmenizi öneririz. Yeni şifreniz en az 6 karakter olmalıdır.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.blue.shade800,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mevcut Şifre
                  Text(
                    'Mevcut Şifre',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordField(
                    controller: _currentPasswordController,
                    label: 'Mevcut şifrenizi girin',
                    icon: Icons.lock_outline,
                    isVisible: _currentPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _currentPasswordVisible = !_currentPasswordVisible;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Yeni Şifre
                  Text(
                    'Yeni Şifre',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'Yeni şifrenizi girin',
                    icon: Icons.lock_outline,
                    isVisible: _newPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _newPasswordVisible = !_newPasswordVisible;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Yeni Şifre Tekrar
                  Text(
                    'Yeni Şifre (Tekrar)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Yeni şifrenizi tekrar girin',
                    icon: Icons.lock_outline,
                    isVisible: _confirmPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // Kaydet Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: passwordViewModel.isUpdating ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.6),
                      ),
                      child: passwordViewModel.isUpdating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Şifreyi Değiştir',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[800],
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[400],
            ),
            onPressed: onVisibilityToggle,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
