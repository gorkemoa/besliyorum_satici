import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../viewmodels/address_viewmodel.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../models/address/address_model.dart';
import '../../../models/address/city_model.dart';
import '../../../models/address/district_model.dart';
import '../../../models/address/neighborhood_model.dart';
import '../../../models/address/address_type_model.dart';
import '../../main_navigation.dart';

class AddressFormPage extends StatefulWidget {
  final AddressModel? existingAddress;
  final int? requiredAddressTypeId;

  const AddressFormPage({
    super.key,
    this.existingAddress,
    this.requiredAddressTypeId,
  });

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  bool _isInitializing = true;

  bool get isEditing => widget.existingAddress != null;
  bool get isRequiredAddressMode => widget.requiredAddressTypeId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  Future<void> _initializeForm() async {
    final addressViewModel = Provider.of<AddressViewModel>(
      context,
      listen: false,
    );

    addressViewModel.clearFormSelections();

    await Future.wait([
      addressViewModel.fetchAddressTypes(),
      addressViewModel.fetchCities(),
    ]);

    if (isEditing && mounted) {
      final existingAddress = widget.existingAddress!;
      _addressController.text = existingAddress.address;

      addressViewModel.setAddressTypeByName(existingAddress.addressType);
      await addressViewModel.setCityByName(existingAddress.cityName);
      await addressViewModel.setDistrictByName(existingAddress.districtName);
      addressViewModel.setNeighborhoodByName(existingAddress.neighborhoodName);
    } else if (widget.requiredAddressTypeId != null && mounted) {
      addressViewModel.setAddressTypeById(widget.requiredAddressTypeId!);
    }

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final addressViewModel = Provider.of<AddressViewModel>(
      context,
      listen: false,
    );
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final token = authViewModel.loginResponse?.data?.token;
    if (token == null) {
      _showError('Oturum bilgisi bulunamadı');
      return;
    }

    if (!isEditing && addressViewModel.selectedAddressType == null) {
      _showError('Lütfen adres tipini seçin');
      return;
    }
    if (addressViewModel.selectedCity == null) {
      _showError('Lütfen il seçin');
      return;
    }
    if (addressViewModel.selectedDistrict == null) {
      _showError('Lütfen ilçe seçin');
      return;
    }
    if (addressViewModel.selectedNeighborhood == null) {
      _showError('Lütfen mahalle seçin');
      return;
    }

    bool success;

    if (isEditing) {
      success = await addressViewModel.updateAddress(
        userToken: token,
        addressID: widget.existingAddress!.addressID,
        addressCity: addressViewModel.selectedCity!.cityNO,
        addressDistrict: addressViewModel.selectedDistrict!.districtNO,
        addressNeighborhood:
            addressViewModel.selectedNeighborhood!.neighbourhoodNo,
        address: _addressController.text.trim(),
      );
    } else {
      success = await addressViewModel.addAddress(
        userToken: token,
        addressType: addressViewModel.selectedAddressType!.typeID,
        addressCity: addressViewModel.selectedCity!.cityNO,
        addressDistrict: addressViewModel.selectedDistrict!.districtNO,
        addressNeighborhood:
            addressViewModel.selectedNeighborhood!.neighbourhoodNo,
        address: _addressController.text.trim(),
      );
    }

    if (success && mounted) {
      await addressViewModel.fetchAddresses(token);

      if (widget.requiredAddressTypeId != null && mounted) {
        _showSuccess('Adres eklendi');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
        return;
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        _showSuccess(isEditing ? 'Adres güncellendi' : 'Adres eklendi');
      }
    } else if (mounted && addressViewModel.errorMessage != null) {
      _showError(addressViewModel.errorMessage!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showCupertinoPicker<T>({
    required String title,
    required List<T> items,
    required T? selectedItem,
    required String Function(T) displayText,
    required void Function(T) onSelected,
  }) {
    if (items.isEmpty) return;

    int initialIndex = 0;
    if (selectedItem != null) {
      final index = items.indexOf(selectedItem);
      if (index >= 0) initialIndex = index;
    }

    int currentIndex = initialIndex;

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ButtonTheme ve Material ekleyerek metin stili garantilenir
                    Material(
                      color: Colors.transparent,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'İptal',
                          style: TextStyle(
                            color: Colors.grey[600],
                            decoration: TextDecoration.none,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text(
                          'Tamam',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        onPressed: () {
                          onSelected(items[currentIndex]);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  itemExtent: 40,
                  backgroundColor: Colors.white,
                  onSelectedItemChanged: (index) {
                    currentIndex = index;
                  },
                  children: items.map((item) {
                    // DÜZELTME: Picker içindeki elemanlara decoration: TextDecoration.none EKLENDİ
                    return Center(
                      child: Text(
                        displayText(item),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          decoration:
                              TextDecoration.none, // SARI ÇİZGİYİ BU KALDIRIR
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle;
    if (isRequiredAddressMode) {
      appBarTitle = 'Zorunlu Adres Ekle';
    } else if (isEditing) {
      appBarTitle = 'Adresi Düzenle';
    } else {
      appBarTitle = 'Yeni Adres';
    }

    return PopScope(
      canPop: !isRequiredAddressMode,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          leading: isRequiredAddressMode
              ? null
              : IconButton(
                  icon: Image.asset(
                    'assets/Icons/geri.png',
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
          automaticallyImplyLeading: !isRequiredAddressMode,
          centerTitle: true,
          title: Text(
            appBarTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: _isInitializing
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
            : Consumer<AddressViewModel>(
                builder: (context, viewModel, child) {
                  return Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        if (isRequiredAddressMode) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Devam edebilmek için bu adresi eklemeniz gerekmektedir.',
                                    style: TextStyle(
                                      color: const Color(0xFFE65100),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (!isEditing) ...[
                          _buildPickerField(
                            label: 'Adres Tipi',
                            value: viewModel.selectedAddressType?.typeName,
                            placeholder: 'Seçiniz',
                            isLoading: viewModel.isAddressTypesLoading,
                            isEnabled: !isRequiredAddressMode,
                            onTap: () => _showCupertinoPicker<AddressTypeModel>(
                              title: 'Adres Tipi',
                              items: viewModel.addressTypes,
                              selectedItem: viewModel.selectedAddressType,
                              displayText: (item) => item.typeName,
                              onSelected: viewModel.setSelectedAddressType,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        _buildPickerField(
                          label: 'İl',
                          value: viewModel.selectedCity?.cityName,
                          placeholder: 'Seçiniz',
                          isLoading: viewModel.isCitiesLoading,
                          onTap: () => _showCupertinoPicker<CityModel>(
                            title: 'İl Seçin',
                            items: viewModel.cities,
                            selectedItem: viewModel.selectedCity,
                            displayText: (item) => item.cityName,
                            onSelected: viewModel.setSelectedCity,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildPickerField(
                          label: 'İlçe',
                          value: viewModel.selectedDistrict?.districtName,
                          placeholder: viewModel.selectedCity == null
                              ? 'Önce il seçin'
                              : 'Seçiniz',
                          isLoading: viewModel.isDistrictsLoading,
                          isEnabled: viewModel.selectedCity != null,
                          onTap: () => _showCupertinoPicker<DistrictModel>(
                            title: 'İlçe Seçin',
                            items: viewModel.districts,
                            selectedItem: viewModel.selectedDistrict,
                            displayText: (item) => item.districtName,
                            onSelected: viewModel.setSelectedDistrict,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildPickerField(
                          label: 'Mahalle',
                          value:
                              viewModel.selectedNeighborhood?.neighbourhoodName,
                          placeholder: viewModel.selectedDistrict == null
                              ? 'Önce ilçe seçin'
                              : 'Seçiniz',
                          isLoading: viewModel.isNeighborhoodsLoading,
                          isEnabled: viewModel.selectedDistrict != null,
                          onTap: () => _showCupertinoPicker<NeighborhoodModel>(
                            title: 'Mahalle Seçin',
                            items: viewModel.neighborhoods,
                            selectedItem: viewModel.selectedNeighborhood,
                            displayText: (item) => item.neighbourhoodName,
                            onSelected: viewModel.setSelectedNeighborhood,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Adres Detayı'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 3,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Sokak, bina no, daire no...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.all(16),
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
                              borderSide: const BorderSide(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Adres detayı gerekli';
                            }
                            if (value.trim().length < 10) {
                              return 'En az 10 karakter girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: viewModel.isSaving ? null : _saveAddress,
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
                            child: viewModel.isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isEditing ? 'Güncelle' : 'Kaydet',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
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

  Widget _buildPickerField({
    required String label,
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
    bool isLoading = false,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isEnabled && !isLoading ? onTap : null,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.grey[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  // DÜZELTME: Material Widget eklendi. Metin stilini garantiye alır.
                  child: Material(
                    type: MaterialType.transparency,
                    child: isLoading
                        ? Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Yükleniyor...',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[400],
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            value ?? placeholder,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              color: value != null
                                  ? Colors.black87
                                  : Colors.grey[400],
                              decoration: TextDecoration.none,
                            ),
                          ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isEnabled ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
