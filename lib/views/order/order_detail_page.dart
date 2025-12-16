import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../models/order/order_detail_model.dart';
import '../auth/login_page.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderID;

  const OrderDetailPage({super.key, required this.orderID});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<OrderViewModel>(context, listen: false).resetDetailState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderDetail();
    });
  }

  void _loadOrderDetail() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    final token = authViewModel.loginResponse?.data?.token;

    if (token != null) {
      orderViewModel.getOrderDetail(token, widget.orderID);
    }
  }

  Future<void> _openTrackingUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kargo takip linki açılamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label kopyalandı'),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 2),
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
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            color: Colors.grey,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Sipariş Detayı',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isDetailLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (viewModel.detailErrorMessage != null) {
            if (viewModel.detailErrorMessage == '403_LOGOUT') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              });
              return const SizedBox.shrink();
            }
            return _buildErrorState(viewModel.detailErrorMessage!);
          }

          if (viewModel.orderDetail == null) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: () async => _loadOrderDetail(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(viewModel.orderDetail!),
                  const SizedBox(height: 16),
                  _buildOrderSummary(viewModel.orderDetail!),
                  const SizedBox(height: 16),
                  _buildProductsSection(viewModel.orderDetail!),
                  const SizedBox(height: 16),
                  _buildShippingAddressSection(viewModel.orderDetail!),
                  const SizedBox(height: 16),
                  _buildBillingAddressSection(viewModel.orderDetail!),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bir hata oluştu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadOrderDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tekrar Dene',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sipariş bulunamadı',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sipariş başlık kartı - Kod, Tarih ve Durum
  Widget _buildOrderHeader(OrderDetailData order) {
    final statusColor = Color(order.statusColor.colorValue);
    final displayColor = order.isCanceled ? Colors.red : statusColor;
    final displayText = order.isCanceled
        ? 'İptal Edildi'
        : order.orderStatusName;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.orderCode,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _copyToClipboard(order.orderCode, 'Sipariş kodu'),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.orderDate,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: displayColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: displayColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sipariş özeti - Tutar, İndirim, Ödeme, Teslimat
  Widget _buildOrderSummary(OrderDetailData order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sipariş Özeti',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            icon: Icons.payments_outlined,
            label: 'Toplam Tutar',
            value: order.orderAmount,
            valueColor: AppTheme.primaryColor,
            isBold: true,
          ),
          if (order.orderDiscount.isNotEmpty &&
              order.orderDiscount != '0' &&
              order.orderDiscount != '0,00 TL') ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              icon: Icons.discount_outlined,
              label: 'İndirim',
              value: '-${order.orderDiscount}',
              valueColor: Colors.green,
            ),
          ],
          const SizedBox(height: 12),
          _buildSummaryRow(
            icon: Icons.credit_card_outlined,
            label: 'Ödeme Yöntemi',
            value: order.paymentType,
            valueColor: Colors.blue,
          ),
          if (order.deliveryDate.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              icon: Icons.local_shipping_outlined,
              label: 'Teslimat Tarihi',
              value: order.deliveryDate,
              valueColor: Colors.purple,
            ),
          ],
          if (order.orderDescription.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note_outlined, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      order.orderDescription,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: valueColor.withOpacity(0.7)),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? valueColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Ürünler bölümü
  Widget _buildProductsSection(OrderDetailData order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ürünler',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),

                child: Text(
                  '${order.products.length} ürün',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...order.products.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return Column(
              children: [
                _buildProductCard(product),
                if (index < order.products.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.grey[100], height: 1),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductCard(OrderProduct product) {
    final statusColor = Color(product.productStatusColor.colorValue);
    final displayColor = product.canceled ? Colors.red : statusColor;
    final displayStatus = product.canceled
        ? 'İptal Edildi'
        : product.statusName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ürün resmi
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.productImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            // Ürün bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.variants.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.variants,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.currentQuantity} adet',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      Text(
                        product.totalPrice,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Ürün durumu ve kargo bilgisi
        Row(
          children: [
            // Durum badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: displayColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                displayStatus,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: displayColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Kargo bilgisi
            if (product.isCargo && product.cargoCompany.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 12,
                      color: Colors.purple[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.cargoCompany,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple[700],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        // Kargo takip butonu
        if (product.isCargo &&
            product.trackingNumber.isNotEmpty &&
            product.trackingURL.isNotEmpty) ...[
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _openTrackingUrl(product.trackingURL),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Takip Numarası',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.trackingNumber,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Takip Et',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        // İptal bilgisi
        if (product.canceled && product.cancelDesc.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.red[400],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İptal Sebebi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.cancelDesc,
                        style: TextStyle(fontSize: 12, color: Colors.red[600]),
                      ),
                      if (product.cancelDate.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.cancelDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[400],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Teslimat adresi bölümü
  Widget _buildShippingAddressSection(OrderDetailData order) {
    return _buildAddressCard(
      title: 'Teslimat Adresi',
      icon: Icons.location_on_outlined,
      iconColor: Colors.green,
      address: order.shippingAddress,
    );
  }

  /// Fatura adresi bölümü
  Widget _buildBillingAddressSection(OrderDetailData order) {
    return _buildAddressCard(
      title: 'Fatura Adresi',
      icon: Icons.receipt_outlined,
      iconColor: Colors.blue,
      address: order.billingAddress,
      showInvoiceDetails: true,
    );
  }

  Widget _buildAddressCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required OrderAddress address,
    bool showInvoiceDetails = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Alıcı adı
          _buildAddressRow(
            icon: Icons.person_outline_rounded,
            label: 'Alıcı',
            value: address.addressName,
          ),
          const SizedBox(height: 10),
          // Adres tipi
          _buildAddressRow(
            icon: Icons.business_outlined,
            label: 'Tip',
            value: address.addressType,
          ),
          const SizedBox(height: 10),
          // Tam adres
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.place_outlined, size: 18, color: Colors.grey[400]),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adres',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Fatura detayları
          if (showInvoiceDetails) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.grey[100], height: 1),
            const SizedBox(height: 16),
            // Kurumsal bilgiler
            if (address.isCorporate && address.realCompanyName.isNotEmpty) ...[
              _buildAddressRow(
                icon: Icons.apartment_rounded,
                label: 'Şirket',
                value: address.realCompanyName,
              ),
              const SizedBox(height: 10),
            ],
            if (address.isCorporate && address.taxNumber.isNotEmpty) ...[
              _buildAddressRow(
                icon: Icons.numbers_rounded,
                label: 'Vergi No',
                value: address.taxNumber,
              ),
              const SizedBox(height: 10),
            ],
            if (address.isCorporate &&
                address.taxAdministration.isNotEmpty) ...[
              _buildAddressRow(
                icon: Icons.account_balance_outlined,
                label: 'Vergi Dairesi',
                value: address.taxAdministration,
              ),
              const SizedBox(height: 10),
            ],
            // TC Kimlik
            if (!address.isCorporate && address.identityNumber.isNotEmpty)
              _buildAddressRow(
                icon: Icons.badge_outlined,
                label: 'TC Kimlik',
                value: _maskIdentityNumber(address.identityNumber),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// TC Kimlik numarasını maskeler
  String _maskIdentityNumber(String identity) {
    if (identity.length >= 11) {
      return '${identity.substring(0, 3)}****${identity.substring(7)}';
    }
    return identity;
  }
}
