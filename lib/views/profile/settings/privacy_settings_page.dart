import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

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
            icon: Icons.description_outlined,
            title: 'Kullanım Koşulları',
            subtitle: 'Uygulama kullanım koşullarını görüntüle',
            onTap: () {
              // TODO: Kullanım koşulları sayfasına yönlendir
            },
          ),

          _buildPolicyTile(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: 'Gizlilik Politikası',
            subtitle: 'Gizlilik politikamızı görüntüle',
            onTap: () {
              // TODO: Gizlilik politikası sayfasına yönlendir
            },
          ),

          _buildPolicyTile(
            context: context,
            icon: Icons.shield_outlined,
            title: 'KVKK Aydınlatma Metni',
            subtitle: 'Kişisel verilerin korunması',
            onTap: () {
              _launchURL('https://www.besliyorum.com/kvkk');
            },
          ),

          _buildPolicyTile(
            context: context,
            icon: Icons.storefront_outlined,
            title: 'Satıcı Sözleşmesi',
            subtitle: 'Satıcı sözleşmesini görüntüle',
            onTap: () {
              // TODO: Satıcı sözleşmesi sayfasına yönlendir
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
              // TODO: Şifre değiştirme sayfası
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hesabı Sil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Vazgeç',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Hesap silme işlemi
            },
            child: Text(
              'Sil',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
