import 'package:besliyorum_satici/core/theme/app_theme.dart';
import 'package:besliyorum_satici/viewmodels/about_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında ayarları yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AboutViewModel>().loadSettings();
    });
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Link açılamadı: $url')));
      }
    }
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    IconData? icon,
    String? url,
    VoidCallback? onTap,
  }) {
    final isClickable = url != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isClickable ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: AppTheme.primaryColor, size: 22),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isClickable
                              ? AppTheme.primaryColor
                              : AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isClickable) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 14.5,
          color: Colors.grey.shade700,
          height: 1.6,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  IconData _getIconForKey(String key) {
    switch (key) {
      case 'website':
        return Icons.language_rounded;
      case 'email':
        return Icons.email_outlined;
      case 'phone_number':
        return Icons.phone_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Hakkımızda',
          // Başlık rengi burada belirlendiği için bozulmaz
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.secondaryColor,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,

        // DEĞİŞİKLİK BURADA: Geri gelme iconunu beyaz yapar
        iconTheme: const IconThemeData(color: Colors.white),

        // Alternatif olarak foregroundColor: Colors.white da diyebilirdin
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AboutViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bir Hata Oluştu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      viewModel.error!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => viewModel.loadSettings(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text(
                        'Tekrar Dene',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final settings = viewModel.leftPanelSettings;
          if (settings == null) {
            return Center(
              child: Text(
                'Ayarlar bulunamadı',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            );
          }

          final descriptions = settings.fields
              .where(
                (f) => f.key.startsWith('description_') && f.settings.isVisible,
              )
              .toList();

          final contacts = settings.fields
              .where(
                (f) =>
                    !f.key.startsWith('description_') && f.settings.isVisible,
              )
              .toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.85),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        
                        child: Image.asset(
                          'assets/Icons/bes-logo-beyaz-sloganli.png', // Dosya yolunun doğru olduğundan emin ol (örn: assets/images/logo.png)
                          width: 100,
                          height: 100,
                          color: Colors
                              .white, // Logonun beyaz olmasını istemiyorsan bu satırı sil
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Besliyorum Satıcı Paneli",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Description Cards
                if (descriptions.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hakkımızda',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...descriptions.map(
                          (field) => _buildDescriptionCard(field.settings.text),
                        ),
                      ],
                    ),
                  ),
                ],

                // Contact Section
                if (contacts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'İletişim',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...contacts.map(
                          (field) => _buildInfoCard(
                            title: field.name,
                            content: field.settings.text,
                            icon: _getIconForKey(field.key),
                            url: field.settings.url,
                            onTap: field.settings.url != null
                                ? () => _launchUrl(field.settings.url)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
