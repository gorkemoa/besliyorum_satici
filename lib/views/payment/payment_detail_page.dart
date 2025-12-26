import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/payment_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../models/payment/payment_detail_model.dart';
import '../../models/order/order_detail_model.dart';
import '../auth/login_page.dart';

class PaymentDetailPage extends StatefulWidget {
  final int paymentID;
  final String payDate;
  final int orderID;

  const PaymentDetailPage({
    super.key,
    required this.paymentID,
    required this.payDate,
    required this.orderID,
  });

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentDetail();
    });
  }

  void _loadPaymentDetail() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final paymentViewModel = Provider.of<PaymentViewModel>(
      context,
      listen: false,
    );
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    final token = authViewModel.loginResponse?.data?.token;

    if (token != null) {
      paymentViewModel.getPaymentDetail(token, widget.paymentID);
      // Sipariş detayını da yükle
      orderViewModel.getOrderDetail(token, widget.orderID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const ImageIcon(
            AssetImage('assets/Icons/geri.png'),
            size: 20,
            color: AppTheme.secondaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ödeme Detayı',
          style: GoogleFonts.poppins(
            color: AppTheme.secondaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<PaymentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.detailErrorMessage == '403_LOGOUT') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            });
            return const SizedBox.shrink();
          }

          if (viewModel.isLoadingDetail) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (viewModel.detailErrorMessage != null) {
            return _buildErrorState(viewModel.detailErrorMessage!);
          }

          if (viewModel.paymentDetail == null) {
            return Center(
              child: Text(
                'Ödeme detayı bulunamadı',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            );
          }

          final detail = viewModel.paymentDetail!;

          return RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: () async => _loadPaymentDetail(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeaderCard(detail),
                  const SizedBox(height: 12),
                  _buildSummaryCard(detail),
                  const SizedBox(height: 12),
                  _buildDetailsList(detail),
                  const SizedBox(height: 12),
                  _buildOrderDetailSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderDetailSection() {
    return Consumer<OrderViewModel>(
      builder: (context, orderViewModel, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.grey.shade100,
              highlightColor: Colors.grey.shade50,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              childrenPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              title: Text(
                'Sipariş Detayı',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                'Sipariş #${widget.orderID}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey[400],
                size: 24,
              ),
              children: [
                Divider(height: 1, color: Colors.grey.shade200),
                _buildOrderDetailContent(orderViewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderDetailContent(OrderViewModel orderViewModel) {
    if (orderViewModel.isDetailLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (orderViewModel.detailErrorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorColor, size: 32),
            const SizedBox(height: 8),
            Text(
              orderViewModel.detailErrorMessage!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final orderDetail = orderViewModel.orderDetail;
    if (orderDetail == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Sipariş detayı bulunamadı',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sipariş bilgileri
          _buildOrderInfoCard(orderDetail),
          const SizedBox(height: 16),
          // Ürünler
          Text(
            'Ürünler (${orderDetail.products.length})',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderDetail.products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _buildOrderProductCard(orderDetail.products[index]),
          ),
          const SizedBox(height: 16),
          // Adres bilgileri
          _buildAddressAccordion(orderDetail),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(OrderDetailData orderDetail) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildOrderInfoRow('Sipariş Kodu', orderDetail.orderCode),
          const SizedBox(height: 8),
          _buildOrderInfoRow('Sipariş Tarihi', orderDetail.orderDate),
          const SizedBox(height: 8),
          _buildOrderInfoRow('Teslim Tarihi', orderDetail.deliveryDate),
          const SizedBox(height: 8),
          _buildOrderInfoRow('Ödeme Tipi', orderDetail.paymentType),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Durum',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: orderDetail.isCanceled
                      ? AppTheme.errorColor.withOpacity(0.1)
                      : AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  orderDetail.isCanceled
                      ? 'İptal Edildi'
                      : orderDetail.orderStatusName,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: orderDetail.isCanceled
                        ? AppTheme.errorColor
                        : AppTheme.successColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _buildOrderInfoRow(
            'Sipariş Tutarı',
            orderDetail.orderAmount,
            isBold: true,
          ),
          if (orderDetail.orderDiscount.isNotEmpty &&
              orderDetail.orderDiscount != '0,00 TL') ...[
            const SizedBox(height: 8),
            _buildOrderInfoRow(
              'İndirim',
              orderDetail.orderDiscount,
              valueColor: AppTheme.successColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderProductCard(OrderProduct product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ürün resmi
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.productImage.isNotEmpty
                ? Image.network(
                    product.productImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.variants.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.variants,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${product.quantity} Adet',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      product.totalPrice,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                if (product.canceled) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'İptal Edildi',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ),
                ] else if (product.statusName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.statusName,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressAccordion(OrderDetailData orderDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adres Bilgileri',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // Teslimat Adresi
        _buildAddressCard(
          title: 'Teslimat Adresi',
          icon: Icons.local_shipping_outlined,
          address: orderDetail.shippingAddress,
        ),
        const SizedBox(height: 8),
        // Fatura Adresi
        _buildAddressCard(
          title: 'Fatura Adresi',
          icon: Icons.receipt_outlined,
          address: orderDetail.billingAddress,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            address.addressName,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address.address,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          if (showInvoiceDetails && address.isCorporate) ...[
            const SizedBox(height: 8),
            Divider(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            _buildInvoiceDetailRow('Firma', address.realCompanyName),
            _buildInvoiceDetailRow('Vergi No', address.taxNumber),
            _buildInvoiceDetailRow('Vergi Dairesi', address.taxAdministration),
          ] else if (showInvoiceDetails &&
              !address.isCorporate &&
              address.identityNumber.isNotEmpty) ...[
            const SizedBox(height: 8),
            Divider(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            _buildInvoiceDetailRow(
              'TC No',
              _maskIdentity(address.identityNumber),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _maskIdentity(String identity) {
    if (identity.length >= 11) {
      return '${identity.substring(0, 3)}****${identity.substring(7)}';
    }
    return identity;
  }

  Widget _buildHeaderCard(PaymentDetail detail) {
    final isPaid = detail.isPaid;
    final statusColor = isPaid ? AppTheme.successColor : AppTheme.primaryColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sipariş #${detail.orderID}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail.payDate,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
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

                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaid ? Icons.check_circle : Icons.access_time,
                      color: statusColor,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPaid ? 'Ödendi' : 'Beklemede',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(PaymentDetail detail) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'NET ÖDEME TUTARI',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            detail.netAmount.amount,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              detail.netAmount.description,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList(PaymentDetail detail) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Ödeme Detayları',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildDetailItem(
            'Satış Tutarı',
            detail.salesAmount,
            Icons.trending_up,
            AppTheme.successColor,
          ),
          _buildDetailItem(
            'Kargo Kesintisi',
            detail.cargoDeduction,
            Icons.local_shipping_outlined,
            Colors.orange,
          ),
          _buildDetailItem(
            'Platform Komisyonu',
            detail.platformFee,
            Icons.payment,
            Colors.purple,
          ),
          _buildDetailItem(
            'E-Ticaret Stopajı',
            detail.ecommerceWithholding,
            Icons.account_balance_outlined,
            Colors.blue,
          ),
          _buildDetailItem(
            'Komisyon Kesintisi',
            detail.commissionDeduction,
            Icons.percent,
            Colors.red,
          ),
          _buildDetailItem(
            'Diğer Ücretler',
            detail.otherFees,
            Icons.receipt_long_outlined,
            Colors.teal,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    String title,
    AmountDetail detail,
    IconData icon,
    Color color, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.grey.shade100,
            highlightColor: Colors.grey.shade50,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            childrenPadding: EdgeInsets.zero,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  detail.amount,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        detail.description,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadPaymentDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Tekrar Dene',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
