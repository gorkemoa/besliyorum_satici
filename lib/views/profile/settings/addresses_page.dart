import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../viewmodels/address_viewmodel.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../models/address/address_model.dart';
import 'address_form_page.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  Future<void> _loadAddresses() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final addressViewModel = Provider.of<AddressViewModel>(
      context,
      listen: false,
    );

    final token = authViewModel.loginResponse?.data?.token;
    if (token != null) {
      await addressViewModel.fetchAddresses(token);
    }
  }

  Future<void> _navigateToAddAddress() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddressFormPage()),
    );
  }

  Future<void> _navigateToEditAddress(AddressModel address) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddressFormPage(existingAddress: address),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/Icons/geri.png', width: 24, height: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Adreslerim',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.textPrimary, size: 26),
            onPressed: _navigateToAddAddress,
          ),
        ],
      ),
      body: Consumer<AddressViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (viewModel.hasError) {
            return _buildErrorState(viewModel.errorMessage);
          }

          if (!viewModel.hasData) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadAddresses,
            color: AppTheme.primaryColor,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildAddressCard(viewModel.addresses[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              message ?? 'Bir hata oluştu',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _loadAddresses,
              child: const Text(
                'Tekrar Dene',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Henüz adres eklemediniz',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni adres eklemek için + butonuna tıklayın',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return InkWell(
      onTap: () => _navigateToEditAddress(address),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                _buildTypeBadge(address.addressType),
                const Spacer(),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Varsayılan',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
              ],
            ),
            const SizedBox(height: 12),

            // Location
            Text(
              '${address.cityName} / ${address.districtName}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),

            // Address detail
            Text(
              address.address,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color badgeColor;
    switch (type) {
      case 'Fatura':
        badgeColor = const Color(0xFF2196F3);
        break;
      case 'Sevkiyat':
        badgeColor = const Color(0xFFFF9800);
        break;
      case 'İade':
        badgeColor = const Color(0xFF9C27B0);
        break;
      default:
        badgeColor = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }
}
