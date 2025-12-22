import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/components/app_dialog.dart';
import '../../core/theme/app_theme.dart';
import '../../models/auth/location_model.dart';
import '../../viewmodels/register_viewmodel.dart';
import 'contract_viewer_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxNoController = TextEditingController();
  
  Timer? _storeNameDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegisterViewModel>().loadCities();
    });
    
    // Store name debounce listener
    _storeNameController.addListener(_onStoreNameChanged);
  }
  
  void _onStoreNameChanged() {
    // Cancel previous timer
    _storeNameDebounce?.cancel();
    
    final storeName = _storeNameController.text.trim();
    
    // Reset validation if empty
    if (storeName.isEmpty) {
      context.read<RegisterViewModel>().resetStoreNameValidation();
      return;
    }
    
    // Start new timer (1.5 seconds debounce)
    _storeNameDebounce = Timer(const Duration(milliseconds: 1500), () {
      if (storeName.isNotEmpty) {
        context.read<RegisterViewModel>().checkStoreName(storeName);
      }
    });
  }

  @override
  void dispose() {
    _storeNameDebounce?.cancel();
    _storeNameController.removeListener(_onStoreNameChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _storeNameController.dispose();
    _addressController.dispose();
    _taxNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section with Logo
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: topPadding + 16,
                bottom: 30,
              ),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  // Back Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Image.asset(
                      'assets/Icons/bes-logo-beyaz-sloganli.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

              // Form Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Satıcı Kaydı',
                        textAlign: TextAlign.center,
                        style: textTheme.displayMedium?.copyWith(
                          color: theme.primaryColor,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mağazanızı oluşturmak için bilgilerinizi doldurunuz.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: Kişisel Bilgiler
                      _buildSectionTitle('Kişisel Bilgiler'),
                      const SizedBox(height: 12),

                      // Ad
                      _buildTextField(
                        controller: _firstNameController,
                        hintText: 'Ad *',
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),

                      // Soyad
                      _buildTextField(
                        controller: _lastNameController,
                        hintText: 'Soyad *',
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),

                      // E-posta
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'E-posta *',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      // Telefon
                      _buildTextField(
                        controller: _phoneController,
                        hintText: 'Telefon * (0(5XX) XXX XX XX)',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9\(\)\s]'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Section: Mağaza Bilgileri
                      _buildSectionTitle('Mağaza Bilgileri'),
                      const SizedBox(height: 12),

                      // Mağaza Adı
                      Consumer<RegisterViewModel>(
                        builder: (context, viewModel, child) {
                          return _buildStoreNameField(viewModel);
                        },
                      ),
                      const SizedBox(height: 12),

                      // İşletme Türü
                      Consumer<RegisterViewModel>(
                        builder: (context, viewModel, child) {
                          return _buildStoreTypeSelector(viewModel);
                        },
                      ),
                      const SizedBox(height: 12),

                      // TC/Vergi No
                      Consumer<RegisterViewModel>(
                        builder: (context, viewModel, child) {
                          return _buildTextField(
                            controller: _taxNoController,
                            hintText: viewModel.selectedStoreType == 1
                                ? 'TC Kimlik No * (11 Hane)'
                                : 'Vergi No * (10 Hane)',
                            prefixIcon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                viewModel.selectedStoreType == 1 ? 11 : 10,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Section: Adres Bilgileri
                      _buildSectionTitle('Adres Bilgileri'),
                      const SizedBox(height: 12),

                      // İl Seçimi
                      Consumer<RegisterViewModel>(
                        builder: (context, viewModel, child) {
                          return _buildDropdown<CityModel>(
                            value: viewModel.selectedCity,
                            items: viewModel.cities,
                            hintText: 'İl Seçiniz *',
                            isLoading: viewModel.isLoadingCities,
                            onChanged: (city) => viewModel.setCity(city),
                            itemBuilder: (city) => city.name,
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // İlçe Seçimi
                      Consumer<RegisterViewModel>(
                        builder: (context, viewModel, child) {
                          return _buildDropdown<DistrictModel>(
                            value: viewModel.selectedDistrict,
                            items: viewModel.districts,
                            hintText: 'İlçe Seçiniz *',
                            isLoading: viewModel.isLoadingDistricts,
                            isEnabled: viewModel.selectedCity != null,
                            onChanged: (district) =>
                                viewModel.setDistrict(district),
                            itemBuilder: (district) => district.name,
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Mahalle Seçimi
                      Consumer<RegisterViewModel>(
                        builder: (context, viewModel, child) {
                          return _buildDropdown<NeighborhoodModel>(
                            value: viewModel.selectedNeighborhood,
                            items: viewModel.neighborhoods,
                            hintText: 'Mahalle Seçiniz *',
                            isLoading: viewModel.isLoadingNeighborhoods,
                            isEnabled: viewModel.selectedDistrict != null,
                            onChanged: (neighborhood) =>
                                viewModel.setNeighborhood(neighborhood),
                            itemBuilder: (neighborhood) => neighborhood.name,
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Adres
                      _buildTextField(
                        controller: _addressController,
                        hintText: 'Açık Adres *',
                        prefixIcon: Icons.location_on_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Section: Sözleşmeler
                      _buildSectionTitle('Sözleşmeler'),
                      const SizedBox(height: 12),

                      // Sözleşme Onayları
                      Consumer<RegisterViewModel>(
                        builder: (context, viewModel, child) {
                          return Column(
                            children: [
                              _buildCheckboxTile(
                                value: viewModel.isPolicy,
                                title: 'Üyelik Sözleşmesi',
                                subtitle:
                                    'Sözleşmeyi okumak için tıklayın.',
                                onTitleTap: () => showContractBottomSheet(
                                  context: context,
                                  contractType: ContractType.seller,
                                  onAccepted: () => viewModel.setPolicy(true),
                                ),
                              ),
                              _buildCheckboxTile(
                                value: viewModel.isIyzicoPolicy,
                                title: 'iyzico Sözleşmesi',
                                subtitle:
                                    'Sözleşmeyi okumak için tıklayın.',
                                onTitleTap: () => showContractBottomSheet(
                                  context: context,
                                  contractType: ContractType.iyzico,
                                  onAccepted: () => viewModel.setIyzicoPolicy(true),
                                ),
                              ),
                              _buildCheckboxTile(
                                value: viewModel.isKvkkPolicy,
                                title: 'KVKK Sözleşmesi',
                                subtitle:
                                    'Sözleşmeyi okumak için tıklayın.',
                                onTitleTap: () => showContractBottomSheet(
                                  context: context,
                                  contractType: ContractType.kvkk,
                                  onAccepted: () => viewModel.setKvkkPolicy(true),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Kayıt Ol Butonu
                      Consumer<RegisterViewModel>(
                        builder: (context, viewModel, child) {
                          return ElevatedButton(
                            onPressed: viewModel.isLoading
                                ? null
                                : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: viewModel.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'KAYIT OL',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Giriş Yap Linki
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Zaten hesabınız var mı? ',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Text(
                              'Giriş Yap',
                              style: textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFFFF8A65),
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFFFF8A65),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppTheme.textSecondary)
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildStoreNameField(RegisterViewModel viewModel) {
    Color? borderColor;
    Widget? suffixWidget;

    if (viewModel.isCheckingStoreName) {
      suffixWidget = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppTheme.primaryColor,
        ),
      );
    } else if (viewModel.isStoreNameAvailable == true) {
      borderColor = Colors.green;
      suffixWidget = const Icon(Icons.check_circle, color: Colors.green);
    } else if (viewModel.isStoreNameAvailable == false) {
      borderColor = Colors.red;
      suffixWidget = const Icon(Icons.error, color: Colors.red);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _storeNameController,
          decoration: InputDecoration(
            hintText: 'Mağaza Adı *',
            prefixIcon: const Icon(Icons.store_outlined, color: AppTheme.textSecondary),
            suffixIcon: suffixWidget != null
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: suffixWidget,
                  )
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor ?? AppTheme.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
        if (viewModel.storeNameError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              viewModel.storeNameError!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
        if (viewModel.isStoreNameAvailable == true)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              'Mağaza adı kullanılabilir.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.green,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStoreTypeSelector(RegisterViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => viewModel.setStoreType(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: viewModel.selectedStoreType == 1
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Şahıs Şirketi',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: viewModel.selectedStoreType == 1
                        ? Colors.white
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => viewModel.setStoreType(2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: viewModel.selectedStoreType == 2
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Şirket',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: viewModel.selectedStoreType == 2
                        ? Colors.white
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String hintText,
    required bool isLoading,
    required void Function(T?) onChanged,
    required String Function(T) itemBuilder,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled && !isLoading && items.isNotEmpty
          ? () => _showCupertinoPicker<T>(
              items: items,
              selectedValue: value,
              onChanged: onChanged,
              itemBuilder: itemBuilder,
              title: hintText.replaceAll(' *', ''),
            )
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.grey.shade50 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      value != null ? itemBuilder(value) : hintText,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: value != null
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: isEnabled
                        ? AppTheme.textSecondary
                        : Colors.grey.shade400,
                  ),
                ],
              ),
      ),
    );
  }

  void _showCupertinoPicker<T>({
    required List<T> items,
    required T? selectedValue,
    required void Function(T?) onChanged,
    required String Function(T) itemBuilder,
    required String title,
  }) {
    int initialIndex = 0;
    if (selectedValue != null) {
      initialIndex = items.indexOf(selectedValue);
      if (initialIndex < 0) initialIndex = 0;
    }

    T? tempSelected = selectedValue ?? (items.isNotEmpty ? items[0] : null);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'İptal',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onChanged(tempSelected);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Seç',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Picker
              SizedBox(
                height: 220,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  magnification: 1.1,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    tempSelected = items[index];
                  },
                  children: items.map((item) {
                    return Center(
                      child: Text(
                        itemBuilder(item),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckboxTile({
    required bool value,
    required String title,
    required String subtitle,
    VoidCallback? onTitleTap,
  }) {
    return GestureDetector(
      onTap: value ? null : onTitleTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            IgnorePointer(
              child: Checkbox(
                value: value,
                onChanged: (_) {},
                activeColor: AppTheme.primaryColor,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: value ? Colors.green : AppTheme.primaryColor,
                              decoration: value ? null : TextDecoration.underline,
                              decorationColor: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (value)
                          const Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Colors.green,
                          )
                        else
                          const Icon(
                            Icons.open_in_new,
                            size: 14,
                            color: AppTheme.primaryColor,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value 
                          ? 'Sözleşme okundu ve kabul edildi.'
                          : subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: value ? Colors.green : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  void _handleRegister() async {
    final viewModel = context.read<RegisterViewModel>();

    // Form validasyonu
    final validationError = viewModel.validateForm(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      storeName: _storeNameController.text,
      address: _addressController.text,
      taxNo: _taxNoController.text,
    );

    if (validationError != null) {
      AppDialog.show(
        context: context,
        title: 'Uyarı',
        content: validationError,
        type: AppDialogType.alert,
        confirmText: 'Tamam',
      );
      return;
    }

    // Register işlemi
    await viewModel.register(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      storeName: _storeNameController.text,
      address: _addressController.text,
      taxNo: _taxNoController.text,
    );

    if (!mounted) return;

    // Response'u göster
    if (viewModel.registerResponse != null) {
      if (viewModel.registerResponse!.success) {
        // Başarılı kayıt
        AppDialog.show(
          context: context,
          title: 'Başarılı',
          content: viewModel.registerResponse!.message,
          type: AppDialogType.info,
          confirmText: 'Tamam',
          onConfirm: () {
            Navigator.of(context).pop(); // Dialog'u kapat
            Navigator.of(context).pop(); // Register sayfasından çık
          },
        );
      } else {
        // Hata durumu
        AppDialog.show(
          context: context,
          title: 'Hata',
          content: viewModel.registerResponse!.message,
          type: AppDialogType.alert,
          confirmText: 'Tamam',
        );
      }
    } else if (viewModel.errorMessage != null) {
      AppDialog.show(
        context: context,
        title: 'Hata',
        content: viewModel.errorMessage!,
        type: AppDialogType.alert,
        confirmText: 'Tamam',
      );
    }
  }
}
