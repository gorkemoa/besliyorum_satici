import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

  void _selectDate() {
    DateTime tempPickedDate = DateTime(2000, 1, 1);
    if (_birthdayController.text.isNotEmpty) {
      try {
        final parts = _birthdayController.text.split('.');
        if (parts.length == 3) {
          tempPickedDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'İptal',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                    const Text(
                      'Tarih Seçiniz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final formattedDate =
                            '${tempPickedDate.day.toString().padLeft(2, '0')}.${tempPickedDate.month.toString().padLeft(2, '0')}.${tempPickedDate.year}';
                        _birthdayController.text = formattedDate;
                        Provider.of<SettingsViewModel>(
                          context,
                          listen: false,
                        ).setUserBirthday(formattedDate);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Bitti',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempPickedDate,
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    tempPickedDate = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
        content:
            settingsViewModel.errorMessage ?? 'Lütfen tüm alanları doldurun',
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
    debugPrint(
      '🔵 [ACCOUNT_SETTINGS] API çağrısı tamamlandı. Başarılı: $success',
    );

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/Icons/geri.png', width: 24, height: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Hesap Bilgileri',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
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
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Uyarı Metni
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!, width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Elektronik Ticaret Aracı Hizmet Sağlayıcı ve Elektronik Ticaret Hizmet Sağlayıcılar Hakkında Yönetmeliğin 5. Maddesi uyarınca telefon numarası ve e-posta adresinizi besliyorum.com\'a bildirmeniz ve doğrulamanız gerekmektedir.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(
                                0xFFE65100,
                              ), // orange[900] equivalent
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Kişisel Bilgiler Başlığı
                  const Text(
                    'Kişisel Bilgiler',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Ad
                  _buildTextField(
                    controller: _firstnameController,
                    label: 'Ad',
                    placeholder: 'Adınızı girin',
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                  ),

                  const SizedBox(height: 16),

                  // Soyad
                  _buildTextField(
                    controller: _lastnameController,
                    label: 'Soyad',
                    placeholder: 'Soyadınızı girin',
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                  ),

                  const SizedBox(height: 16),

                  // E-posta
                  _buildTextField(
                    controller: _emailController,
                    label: 'E-posta',
                    placeholder: 'E-posta adresinizi girin',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  // Telefon
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Telefon',
                    placeholder: 'Telefon numaranızı girin',
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
                    placeholder: 'Seçiniz',
                    readOnly: true,
                    onTap: _selectDate,
                    suffixIcon: Icons.calendar_today,
                  ),

                  const SizedBox(height: 16),

                  // Cinsiyet
                  _buildDropdownField(
                    label: 'Cinsiyet',
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
                    height: 52,
                    child: ElevatedButton(
                      onPressed: settingsViewModel.isUpdating
                          ? null
                          : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: AppTheme.primaryColor
                            .withValues(alpha: 0.6),
                      ),
                      child: settingsViewModel.isUpdating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Değişiklikleri Kaydet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? placeholder,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey[400], size: 20)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: items.contains(value) ? value : items.first,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            dropdownColor: Colors.white,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}
