import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../auth/login_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<ProfileViewModel>(context, listen: false).resetState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final profileViewModel = Provider.of<ProfileViewModel>(
      context,
      listen: false,
    );

    final userId = authViewModel.loginResponse?.data?.userID;
    final token = authViewModel.loginResponse?.data?.token;

    if (userId != null && token != null) {
      await profileViewModel.getUser(userId, token);
    }
  }

  Future<void> _logout() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.logout();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
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
          'Profilim',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              // Eğer ayarlardan veri güncellenmiş olarak dönüldüyse, profil verilerini yenile
              if (result == true && mounted) {
                _loadUserData();
              }
            },
          ),
        ],
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, profileViewModel, child) {
          if (profileViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (profileViewModel.errorMessage != null) {
            if (profileViewModel.errorMessage == '403_LOGOUT') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _logout();
              });
              return const SizedBox.shrink();
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Bir hata oluştu',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: Text(
                      'Tekrar Dene',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final userData = profileViewModel.userData;
          if (userData == null) {
            return const Center(child: Text('Kullanıcı bilgisi bulunamadı'));
          }

          return RefreshIndicator(
            onRefresh: _loadUserData,
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Profil Header
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Profil Fotoğrafı veya Mağaza Logosu
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: userData.profilePhoto.isNotEmpty
                                ? Image.network(
                                    userData.profilePhoto,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            userData.storeLogo.isNotEmpty
                                                ? Image.network(
                                                    userData.storeLogo,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        const Icon(
                                                          Icons.store,
                                                          size: 60,
                                                          color: AppTheme
                                                              .primaryColor,
                                                        ),
                                                  )
                                                : const Icon(
                                                    Icons.store,
                                                    size: 60,
                                                    color: AppTheme
                                                        .primaryColor,
                                                  ),
                                  )
                                : userData.storeLogo.isNotEmpty
                                    ? Image.network(
                                        userData.storeLogo,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.store,
                                                  size: 60,
                                                  color: AppTheme.primaryColor,
                                                ),
                                      )
                                    : const Icon(
                                        Icons.store,
                                        size: 60,
                                        color: AppTheme.primaryColor,
                                      ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // İsim
                        Text(
                          userData.userFullname,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Mağaza Adı
                        Text(
                          userData.storeName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Mağaza Puanı
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                userData.storePoint,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Kullanıcı Bilgileri
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hesap Bilgileri',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          icon: Icons.person_outline,
                          title: 'Kullanıcı Adı',
                          value: userData.username,
                        ),
                        _buildInfoCard(
                          icon: Icons.email_outlined,
                          title: 'E-posta',
                          value: userData.userEmail,
                        ),
                        _buildInfoCard(
                          icon: Icons.phone_outlined,
                          title: 'Telefon',
                          value: userData.userPhone,
                        ),
                        if (userData.userBirthday.isNotEmpty)
                          _buildInfoCard(
                            icon: Icons.cake_outlined,
                            title: 'Doğum Tarihi',
                            value: userData.userBirthday,
                          ),
                        _buildInfoCard(
                          icon: Icons.calendar_today_outlined,
                          title: 'Kayıt Tarihi',
                          value: userData.registerDate,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Mağaza Bilgileri
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mağaza Bilgileri',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          icon: Icons.store_outlined,
                          title: 'Mağaza Adı',
                          value: userData.storeName,
                        ),
                        _buildInfoCard(
                          icon: Icons.inventory_2_outlined,
                          title: 'Toplam Ürün',
                          value:
                              '${userData.statistics.totalSellerProducts} Ürün',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
