import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/components/app_dialog.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/settings_viewmodel.dart';
import '../../auth/login_page.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdayController;

  @override
  void initState() {
    super.initState();
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _birthdayController = TextEditingController();

    Provider.of<SettingsViewModel>(context, listen: false).resetState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final settingsViewModel = Provider.of<SettingsViewModel>(
      context,
      listen: false,
    );

    final userId = authViewModel.loginResponse?.data?.userID;
    final token = authViewModel.loginResponse?.data?.token;

    if (userId != null && token != null) {
      await settingsViewModel.getUser(userId, token);
      _updateControllers();
    }
  }

  void _updateControllers() {
    final settingsViewModel = Provider.of<SettingsViewModel>(
      context,
      listen: false,
    );
    _firstnameController.text = settingsViewModel.userFirstname;
    _lastnameController.text = settingsViewModel.userLastname;
    _emailController.text = settingsViewModel.userEmail;
    _phoneController.text = settingsViewModel.userPhone;
    _birthdayController.text = settingsViewModel.userBirthday;
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
      _birthdayController.text = formattedDate;
      Provider.of<SettingsViewModel>(context, listen: false)
          .setUserBirthday(formattedDate);
    }
  }

  Future<void> _saveChanges() async {
    final settingsViewModel = Provider.of<SettingsViewModel>(
      context,
      listen: false,
    );
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Form değerlerini ViewModel'e aktar
    settingsViewModel.setUserFirstname(_firstnameController.text);
    settingsViewModel.setUserLastname(_lastnameController.text);
    settingsViewModel.setUserEmail(_emailController.text);
    settingsViewModel.setUserPhone(_phoneController.text);
    settingsViewModel.setUserBirthday(_birthdayController.text);

    debugPrint('🔵 [ACCOUNT_SETTINGS] Form değerleri:');
    debugPrint('   Ad: ${_firstnameController.text}');
    debugPrint('   Soyad: ${_lastnameController.text}');
    debugPrint('   Email: ${_emailController.text}');
    debugPrint('   Telefon: ${_phoneController.text}');
    debugPrint('   Doğum Tarihi: ${_birthdayController.text}');
    debugPrint('   Cinsiyet: ${settingsViewModel.userGender}');

    if (!settingsViewModel.validateForm()) {
      debugPrint('❌ [ACCOUNT_SETTINGS] Form validasyonu başarısız!');
      AppDialog.show(
        context: context,
        title: 'Hata',
        content: settingsViewModel.errorMessage ?? 'Lütfen tüm alanları doldurun',
        type: AppDialogType.alert,
        confirmText: 'Tamam',
      );
      return;
    }

    final token = authViewModel.loginResponse?.data?.token;
    if (token == null) {
      debugPrint('❌ [ACCOUNT_SETTINGS] Token bulunamadı!');
      return;
    }

    debugPrint('🔵 [ACCOUNT_SETTINGS] API çağrısı başlıyor...');
    final success = await settingsViewModel.updateUser(token);
    debugPrint('🔵 [ACCOUNT_SETTINGS] API çağrısı tamamlandı. Başarılı: $success');

    if (mounted) {
      if (success) {
        AppDialog.show(
          context: context,
          title: 'Başarılı',
          content: 'Bilgileriniz başarıyla güncellendi',
          type: AppDialogType.info,
          confirmText: 'Tamam',
          onConfirm: () {
            Navigator.of(context).pop(); // Dialog'u kapat
            Navigator.of(context).pop(true); // Sayfayı kapat ve true döndür
          },
        );
      } else if (settingsViewModel.errorMessage == '403_LOGOUT') {
        _logout();
      } else {
        AppDialog.show(
          context: context,
          title: 'Hata',
          content: settingsViewModel.errorMessage ?? 'Güncelleme başarısız',
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
          'Hesap Bilgileri',
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
      body: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          if (settingsViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (settingsViewModel.errorMessage != null) {
            if (settingsViewModel.errorMessage == '403_LOGOUT') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _logout();
              });
              return const SizedBox.shrink();
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Uyarı Metni
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Elektronik Ticaret Aracı Hizmet Sağlayıcı ve Elektronik Ticaret Hizmet Sağlayıcılar Hakkında Yönetmeliğin 5. Maddesi uyarınca telefon numarası ve e-posta adresinizi besliyorum.com\'a bildirmeniz ve doğrulamanız gerekmektedir.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.orange.shade800,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Kişisel Bilgiler Başlığı
                  Text(
                    'Kişisel Bilgiler',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ad
                  _buildTextField(
                    controller: _firstnameController,
                    label: 'Ad',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                  ),

                  const SizedBox(height: 16),

                  // Soyad
                  _buildTextField(
                    controller: _lastnameController,
                    label: 'Soyad',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                  ),

                  const SizedBox(height: 16),

                  // E-posta
                  _buildTextField(
                    controller: _emailController,
                    label: 'E-posta',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  // Telefon
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Telefon',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Doğum Tarihi
                  _buildTextField(
                    controller: _birthdayController,
                    label: 'Doğum Tarihi',
                    icon: Icons.cake_outlined,
                    readOnly: true,
                    onTap: _selectDate,
                    suffixIcon: Icons.calendar_today,
                  ),

                  const SizedBox(height: 16),

                  // Cinsiyet
                  _buildDropdownField(
                    label: 'Cinsiyet',
                    icon: Icons.wc_outlined,
                    value: settingsViewModel.userGender,
                    items: settingsViewModel.genderOptions,
                    onChanged: (value) {
                      if (value != null) {
                        settingsViewModel.setUserGender(value);
                      }
                    },
                  ),

                  const SizedBox(height: 32),

                  // Kaydet Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: settingsViewModel.isUpdating ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: AppTheme.primaryColor.withValues(alpha: 0.6),
                      ),
                      child: settingsViewModel.isUpdating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Değişiklikleri Kaydet',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
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
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        onTap: onTap,
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
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: Colors.grey[400], size: 20)
              : null,
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

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
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
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items.first,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
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
        dropdownColor: Colors.white,
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
      ),
    );
  }
}
