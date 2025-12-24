import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/components/app_dialog.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../models/auth/delete_user_model.dart';
import '../../../services/users_service.dart';
import 'change_password_page.dart';
import '../../auth/login_page.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
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
          'Gizlilik ve Güvenlik',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Sözleşmeler ve Politikalar',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          _buildPolicyTile(
            context: context,
            icon: Icons.handshake_outlined,
            title: 'Satıcı İş Ortaklığı ve E-Ticaret Aracılık Sözleşmesi',
            subtitle: 'İş ortaklığı sözleşmesini görüntüle',
            onTap: () {
              _launchURL('https://www.besliyorum.com/satici-is-ortakligi-ve-elektronik-ticaret-aracilik-hizmetleri-sozlesmesi');
            },
          ),

          _buildPolicyTile(
            context: context,
            icon: Icons.person_add_outlined,
            title: 'Üyelik Sözleşmesi',
            subtitle: 'Üyelik sözleşmesini görüntüle',
            onTap: () {
              _launchURL('https://www.besliyorum.com/uyelik-sozlesmesi');
            },
          ),

          _buildPolicyTile(
            context: context,
            icon: Icons.shopping_cart_outlined,
            title: 'Mesafeli Satış Sözleşmesi',
            subtitle: 'Mesafeli satış sözleşmesini görüntüle',
            onTap: () {
              _launchURL('https://www.besliyorum.com/mesafeli-satis-sozlesmesi');
            },
          ),

          _buildPolicyTile(
            context: context,
            icon: Icons.rule_outlined,
            title: 'Satıcı Kuralları',
            subtitle: 'Satıcı kurallarını görüntüle',
            onTap: () {
              _launchURL('https://www.besliyorum.com/satici-kurallari');
            },
          ),

          _buildPolicyTile(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: 'Gizlilik Politikası',
            subtitle: 'Gizlilik politikamızı görüntüle',
            onTap: () {
              _launchURL('https://www.besliyorum.com/gizlilik-politikasi');
            },
          ),

          _buildPolicyTile(
            context: context,
            icon: Icons.shield_outlined,
            title: 'KVKK Aydınlatma Metni',
            subtitle: 'Kişisel verilerin korunması',
            onTap: () {
              _launchURL('https://www.besliyorum.com/kvkk-aydinlatma-metni');
            },
          ),

          const SizedBox(height: 24),

          Text(
            'Hesap Güvenliği',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          _buildPolicyTile(
            context: context,
            icon: Icons.lock_outline,
            title: 'Şifre Değiştir',
            subtitle: 'Hesap şifrenizi değiştirin',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
          ),

          _buildPolicyTile(
            context: context,
            icon: Icons.delete_outline,
            title: 'Hesabı Sil',
            subtitle: 'Hesabınızı kalıcı olarak silin',
            onTap: () {
              _showDeleteAccountDialog(context);
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.1)
                : AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : AppTheme.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.grey[800],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    AppDialog.show(
      context: context,
      title: 'Hesabı Sil',
      content: 'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz kalıcı olarak silinecektir.',
      type: AppDialogType.confirmation,
      confirmText: 'Devam Et',
      cancelText: 'Vazgeç',
      onConfirm: () {
        Navigator.of(context).pop(); // İlk dialog'u kapat
        _showFinalDeleteConfirmation(context); // İkinci onay dialog'unu göster
      },
      onCancel: () => Navigator.of(context).pop(),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context) {
    AppDialog.show(
      context: context,
      title: 'Son Onay',
      content: 'Bu işlem geri alınamaz! Hesabınızı silmek için tekrar onaylayın.',
      type: AppDialogType.confirmation,
      confirmText: 'Hesabı Sil',
      cancelText: 'Vazgeç',
      onConfirm: () async {
        Navigator.of(context).pop(); // İkinci dialog'u kapat
        await _deleteAccount(context);
      },
      onCancel: () => Navigator.of(context).pop(),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final token = authViewModel.loginResponse?.data?.token;

    if (token == null) {
      if (context.mounted) {
        AppDialog.show(
          context: context,
          title: 'Hata',
          content: 'Oturum bilgisi bulunamadı',
          type: AppDialogType.alert,
          confirmText: 'Tamam',
        );
      }
      return;
    }

    // Loading dialog göster
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      );
    }

    try {
      final usersService = UsersService();
      final request = DeleteUserRequestModel(userToken: token);
      
      debugPrint('🗑️ [PRIVACY_SETTINGS] Hesap silme işlemi başlatılıyor...');
      final response = await usersService.deleteUser(request);
      debugPrint('🗑️ [PRIVACY_SETTINGS] Response alındı: success=${response.success}');

      if (context.mounted) {
        Navigator.of(context).pop(); // Loading dialog'u kapat

        if (response.success && response.code200) {
          // Logout yap
          await authViewModel.logout();
          
          // Login sayfasına yönlendir
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );

            // Başarı mesajı göster
            AppDialog.show(
              context: context,
              title: 'Başarılı',
              content: response.message ?? 'Hesabınız başarıyla silindi',
              type: AppDialogType.info,
              confirmText: 'Tamam',
            );
          }
        } else {
          AppDialog.show(
            context: context,
            title: 'Hata',
            content: response.message ?? response.errorMessage ?? 'Hesap silme işlemi başarısız',
            type: AppDialogType.alert,
            confirmText: 'Tamam',
          );
        }
      }
    } catch (e) {
      debugPrint('🗑️ [PRIVACY_SETTINGS] HATA: $e');
      if (context.mounted) {
        Navigator.of(context).pop(); // Loading dialog'u kapat
        AppDialog.show(
          context: context,
          title: 'Hata',
          content: 'Bir hata oluştu: $e',
          type: AppDialogType.alert,
          confirmText: 'Tamam',
        );
      }
    }
  }
}
