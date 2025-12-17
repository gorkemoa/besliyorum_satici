import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
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
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Sipariş Detayı',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isDetailLoading) {
            return const Center(
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
                  _buildProductsSection(viewModel.orderDetail!),
                  const SizedBox(height: 16),
                  _buildOrderSummary(viewModel.orderDetail!),
                  const SizedBox(height: 16),
                  _buildAddressSection(viewModel.orderDetail!),
                  const SizedBox(height: 16),
                  if (viewModel.orderDetail!.agreement.isNotEmpty)
                    _buildAgreementSection(viewModel.orderDetail!),
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
            Icon(Icons.error_outline_rounded, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Bir hata oluştu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadOrderDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Sipariş bulunamadı',
            style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildOrderHeader(OrderDetailData order) {
    final isCanceled = order.isCanceled;
    final statusText = isCanceled ? 'İptal Edildi' : order.orderStatusName;

    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Sipariş #${order.orderCode}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _copyToClipboard(order.orderCode, 'Sipariş kodu'),
                          child: Icon(Icons.copy_rounded, size: 16, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.orderDate,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(OrderDetailData order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Özet Bilgiler',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        _buildSectionContainer(
          child: Column(
            children: [
              _buildSummaryRow('Ödeme Yöntemi', order.paymentType),
              if (order.deliveryDate.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildSummaryRow('Teslimat Tarihi', order.deliveryDate),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
              ),
              if (order.orderDiscount.isNotEmpty && order.orderDiscount != '0' && order.orderDiscount != '0,00 TL') ...[
                _buildSummaryRow('İndirim', '-${order.orderDiscount}', valueColor: Colors.green),
                const SizedBox(height: 12),
              ],
              _buildSummaryRow('Toplam Tutar', order.orderAmount, isBold: true, valueColor: AppTheme.primaryColor, valueSize: 18),
              if (order.orderDescription.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sipariş Notu',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber[800]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.orderDescription,
                        style: TextStyle(fontSize: 13, color: Colors.amber[900]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? valueColor, double? valueSize}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize ?? 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection(OrderDetailData order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Ürünler (${order.products.length})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: order.products.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildProductCard(order.products[index]),
        ),
      ],
    );
  }

  Widget _buildProductCard(OrderProduct product) {
    final displayStatus = product.canceled ? 'İptal Edildi' : product.statusName;

    return _buildSectionContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.productImage,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[100],
                      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.variants.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.variants,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.currentQuantity} Adet',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          product.totalPrice,
                          style: const TextStyle(
                            fontSize: 14,
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
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16),
              const SizedBox(width: 6),
              Text(
                displayStatus,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (product.isCargo && product.cargoCompany.isNotEmpty) ...[
                const Spacer(),
                Icon(Icons.local_shipping_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  product.cargoCompany,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
          if (product.isCargo && product.trackingNumber.isNotEmpty && product.trackingURL.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _openTrackingUrl(product.trackingURL),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.withOpacity(0.05),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_searching_rounded, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kargo Takip: ${product.trackingNumber}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
          if (product.canceled && product.cancelDesc.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'İptal Nedeni: ${product.cancelDesc}',
                      style: TextStyle(fontSize: 12, color: Colors.red[700]),
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

  Widget _buildAddressSection(OrderDetailData order) {
    return Column(
      children: [
        _buildAddressCard(
          title: 'Teslimat Adresi',
          icon: Icons.local_shipping_outlined,
          address: order.shippingAddress,
        ),
        const SizedBox(height: 16),
        _buildAddressCard(
          title: 'Fatura Adresi',
          icon: Icons.receipt_long_outlined,
          address: order.billingAddress,
          showInvoiceDetails: true,
        ),
      ],
    );
  }

  Widget _buildAddressCard({
    required String title,
    required IconData icon,
    required OrderAddress address,
    bool showInvoiceDetails = false,
  }) {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Text(
            address.addressName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            address.address,
            style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
          ),
          if (showInvoiceDetails && address.isCorporate) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (address.realCompanyName.isNotEmpty)
                    _buildInvoiceRow('Şirket', address.realCompanyName),
                  if (address.taxNumber.isNotEmpty)
                    _buildInvoiceRow('Vergi No', address.taxNumber),
                  if (address.taxAdministration.isNotEmpty)
                    _buildInvoiceRow('Vergi Dairesi', address.taxAdministration),
                ],
              ),
            ),
          ] else if (showInvoiceDetails && !address.isCorporate && address.identityNumber.isNotEmpty) ...[
             const SizedBox(height: 12),
             Container(
               padding: const EdgeInsets.all(10),
               decoration: BoxDecoration(
                 color: Colors.grey[50],
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: Colors.grey[200]!),
               ),
               child: _buildInvoiceRow('TC Kimlik', _maskIdentityNumber(address.identityNumber)),
             ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  String _maskIdentityNumber(String identity) {
    if (identity.length >= 11) {
      return '${identity.substring(0, 3)}****${identity.substring(7)}';
    }
    return identity;
  }

  Widget _buildAgreementSection(OrderDetailData order) {
    return _buildSectionContainer(
      child: InkWell(
        onTap: () => _showAgreementBottomSheet(order.agreement),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.description_outlined, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Mesafeli Satış Sözleşmesi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showAgreementBottomSheet(String agreementContent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sözleşme',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Html(
                    data: agreementContent,
                    style: {
                      "body": Style(
                        fontSize: FontSize(14),
                        lineHeight: LineHeight(1.5),
                      ),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
