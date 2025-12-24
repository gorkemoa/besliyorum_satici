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

class AddressFormPage extends StatefulWidget {
  final AddressModel? existingAddress;

  const AddressFormPage({super.key, this.existingAddress});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  bool get isEditing => widget.existingAddress != null;

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

    // Clear previous selections
    addressViewModel.clearFormSelections();

    // Load initial data
    await Future.wait([
      addressViewModel.fetchAddressTypes(),
      addressViewModel.fetchCities(),
    ]);

    // If editing, populate form
    if (isEditing && mounted) {
      _addressController.text = widget.existingAddress!.address;
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

    // Validate selections
    if (addressViewModel.selectedAddressType == null) {
      _showError('Lütfen adres tipini seçin');
      return;
    }
    if (addressViewModel.selectedCity == null) {
      _showError('Lütfen şehir seçin');
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
      // Update existing address
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
      // Add new address
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
      // Refresh address list and go back
      await addressViewModel.fetchAddresses(token);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/Icons/geri.png',
            width: 25,
            height: 25,
            fit: BoxFit.contain,
            color: Colors.grey,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          isEditing ? 'Adresi Düzenle' : 'Yeni Adres Ekle',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<AddressViewModel>(
        builder: (context, viewModel, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Address Type Dropdown (only for new address)
                if (!isEditing) ...[
                  _buildSectionTitle('Adres Tipi'),
                  const SizedBox(height: 8),
                  _buildAddressTypeDropdown(viewModel),
                  const SizedBox(height: 20),
                ],

                // City Dropdown
                _buildSectionTitle('Şehir'),
                const SizedBox(height: 8),
                _buildCityDropdown(viewModel),
                const SizedBox(height: 20),

                // District Dropdown
                _buildSectionTitle('İlçe'),
                const SizedBox(height: 8),
                _buildDistrictDropdown(viewModel),
                const SizedBox(height: 20),

                // Neighborhood Dropdown
                _buildSectionTitle('Mahalle'),
                const SizedBox(height: 8),
                _buildNeighborhoodDropdown(viewModel),
                const SizedBox(height: 20),

                // Address Text Field
                _buildSectionTitle('Adres Detayı'),
                const SizedBox(height: 8),
                _buildAddressTextField(),
                const SizedBox(height: 32),

                // Save Button
                _buildSaveButton(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildAddressTypeDropdown(AddressViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: viewModel.isAddressTypesLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            )
          : DropdownButtonFormField<AddressTypeModel>(
              value: viewModel.selectedAddressType,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: InputBorder.none,
                hintText: 'Adres tipi seçin',
              ),
              items: viewModel.addressTypes.map((type) {
                return DropdownMenuItem<AddressTypeModel>(
                  value: type,
                  child: Text(type.typeName),
                );
              }).toList(),
              onChanged: (value) {
                viewModel.setSelectedAddressType(value);
              },
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              isExpanded: true,
            ),
    );
  }

  Widget _buildCityDropdown(AddressViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: viewModel.isCitiesLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            )
          : DropdownButtonFormField<CityModel>(
              value: viewModel.selectedCity,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: InputBorder.none,
                hintText: 'Şehir seçin',
              ),
              items: viewModel.cities.map((city) {
                return DropdownMenuItem<CityModel>(
                  value: city,
                  child: Text(city.cityName),
                );
              }).toList(),
              onChanged: (value) {
                viewModel.setSelectedCity(value);
              },
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              isExpanded: true,
            ),
    );
  }

  Widget _buildDistrictDropdown(AddressViewModel viewModel) {
    final isEnabled = viewModel.selectedCity != null;

    return Container(
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: viewModel.isDistrictsLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            )
          : DropdownButtonFormField<DistrictModel>(
              value: viewModel.selectedDistrict,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: InputBorder.none,
                hintText: isEnabled ? 'İlçe seçin' : 'Önce şehir seçin',
              ),
              items: viewModel.districts.map((district) {
                return DropdownMenuItem<DistrictModel>(
                  value: district,
                  child: Text(district.districtName),
                );
              }).toList(),
              onChanged: isEnabled
                  ? (value) {
                      viewModel.setSelectedDistrict(value);
                    }
                  : null,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              isExpanded: true,
            ),
    );
  }

  Widget _buildNeighborhoodDropdown(AddressViewModel viewModel) {
    final isEnabled = viewModel.selectedDistrict != null;

    return Container(
      decoration: BoxDecoration(
        color: isEnabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: viewModel.isNeighborhoodsLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            )
          : DropdownButtonFormField<NeighborhoodModel>(
              value: viewModel.selectedNeighborhood,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: InputBorder.none,
                hintText: isEnabled ? 'Mahalle seçin' : 'Önce ilçe seçin',
              ),
              items: viewModel.neighborhoods.map((neighborhood) {
                return DropdownMenuItem<NeighborhoodModel>(
                  value: neighborhood,
                  child: Text(neighborhood.neighbourhoodName),
                );
              }).toList(),
              onChanged: isEnabled
                  ? (value) {
                      viewModel.setSelectedNeighborhood(value);
                    }
                  : null,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              isExpanded: true,
            ),
    );
  }

  Widget _buildAddressTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: _addressController,
        maxLines: 4,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(16),
          border: InputBorder.none,
          hintText: 'Sokak, cadde, bina no, daire no vb.',
          hintStyle: TextStyle(color: Colors.grey),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Lütfen adres detayını girin';
          }
          if (value.trim().length < 10) {
            return 'Adres en az 10 karakter olmalıdır';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSaveButton(AddressViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
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
        ),
        child: viewModel.isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
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
    );
  }
}
