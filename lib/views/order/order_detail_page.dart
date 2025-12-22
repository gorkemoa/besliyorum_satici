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

  Future<void> _confirmOrder() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    final token = authViewModel.loginResponse?.data?.token;

    if (token == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Siparişi Onayla'),
        content: const Text(
          'Siparişi onaylamak ve işleme almak istediğinize emin misiniz?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await orderViewModel.confirmOrder(token, widget.orderID);

      if (mounted) {
        if (orderViewModel.confirmErrorMessage == '403_LOGOUT') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sipariş başarıyla onaylandı ve işleme alındı'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                orderViewModel.confirmErrorMessage ?? 'Sipariş onaylanamadı',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _cancelOrder() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    final token = authViewModel.loginResponse?.data?.token;
    final orderDetail = orderViewModel.orderDetail;

    if (token == null || orderDetail == null) return;

    // İptal nedenlerini yükle
    await orderViewModel.getOrderCancelTypes();

    if (orderViewModel.cancelTypes.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İptal nedenleri yüklenemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // İptal edilebilir ürünleri filtrele
    final cancelableProducts = orderDetail.products
        .where((p) => !p.canceled && p.currentQuantity > 0)
        .toList();

    if (cancelableProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İptal edilebilir ürün bulunmuyor'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // İptal dialog'unu göster
    final result = await showModalBottomSheet<List<CancelProduct>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CancelOrderBottomSheet(
        products: cancelableProducts,
        orderID: orderDetail.orderID,
        cancelTypes: orderViewModel.cancelTypes,
      ),
    );

    if (result != null && result.isNotEmpty) {
      final success = await orderViewModel.cancelOrder(
        token,
        orderDetail.orderID,
        result,
      );

      if (mounted) {
        if (orderViewModel.cancelErrorMessage == '403_LOGOUT') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                orderViewModel.cancelSuccessMessage ?? 'Ürünler başarıyla iptal edildi',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                orderViewModel.cancelErrorMessage ?? 'Ürünler iptal edilemedi',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _createLabel(String trackingNo) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    final token = authViewModel.loginResponse?.data?.token;
    final orderDetail = orderViewModel.orderDetail;

    if (token == null || orderDetail == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etiket Oluştur'),
        content: Text(
          'Takip No: $trackingNo\n\nBu sipariş için kargo etiketi oluşturmak istediğinize emin misiniz?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await orderViewModel.createLabel(
        token,
        trackingNo,
        orderDetail.orderID,
      );

      if (mounted) {
        if (orderViewModel.createLabelErrorMessage == '403_LOGOUT') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else if (success) {
          // Başarılı - etiketi göster
          _showLabelBottomSheet(orderViewModel.labelData!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                orderViewModel.createLabelErrorMessage ?? 'Etiket oluşturulamadı',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _showLabelBottomSheet(CreateLabelData labelData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
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
                      'Kargo Etiketi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                  child: Column(
                    children: [
                      // Etiket bilgileri
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Etiket başarıyla oluşturuldu!',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Takip No
                      _buildLabelInfoRow('Takip No', labelData.trackingNo),
                      _buildLabelInfoRow('Sipariş Kodu', labelData.orderCode),
                      const SizedBox(height: 16),
                      // Etiket görseli
                      if (labelData.labelUrl.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            labelData.labelUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 100,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Etiket yüklenemedi',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // URL'yi aç butonu
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _openTrackingUrl(labelData.labelUrl),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Etiketi Tarayıcıda Aç'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Tüm siparişi kargoya ver
  Future<void> _addCargoAll() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    final token = authViewModel.loginResponse?.data?.token;
    final orderDetail = orderViewModel.orderDetail;

    if (token == null || orderDetail == null) return;

    // Takip numarası için dialog göster
    final trackingNo = await _showTrackingNoDialog(
      title: 'Tümünü Kargoya Ver',
      message: 'Tüm ürünleri kargoya vermek için takip numarasını girin.',
    );

    if (trackingNo == null || trackingNo.isEmpty) return;

    final success = await orderViewModel.addOrderCargoAll(
      token,
      orderDetail.orderID,
      trackingNo,
    );

    if (mounted) {
      if (orderViewModel.addCargoErrorMessage == '403_LOGOUT') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              orderViewModel.addCargoSuccessMessage ?? 'Sipariş kargoya verildi',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              orderViewModel.addCargoErrorMessage ?? 'Kargo eklenemedi',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Ürünü kargoya ver
  Future<void> _addProductCargo(OrderProduct product) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    final token = authViewModel.loginResponse?.data?.token;
    final orderDetail = orderViewModel.orderDetail;

    if (token == null || orderDetail == null) return;

    // Takip numarası için dialog göster
    final trackingNo = await _showTrackingNoDialog(
      title: 'Ürünü Kargoya Ver',
      message: '${product.productName} ürününü kargoya vermek için takip numarasını girin.',
    );

    if (trackingNo == null || trackingNo.isEmpty) return;

    final success = await orderViewModel.addProductCargo(
      token,
      orderDetail.orderID,
      product.opID,
      trackingNo,
    );

    if (mounted) {
      if (orderViewModel.addCargoErrorMessage == '403_LOGOUT') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              orderViewModel.addCargoSuccessMessage ?? 'Ürün kargoya verildi',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              orderViewModel.addCargoErrorMessage ?? 'Kargo eklenemedi',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Takip numarası giriş dialogu
  Future<String?> _showTrackingNoDialog({
    required String title,
    required String message,
  }) async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Takip Numarası',
                hintText: 'Kargo takip numarasını girin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kargoya Ver'),
          ),
        ],
      ),
    );
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black87,
          ),
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

          return Stack(
            children: [
              RefreshIndicator(
                color: AppTheme.primaryColor,
                onRefresh: () async => _loadOrderDetail(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: (viewModel.orderDetail!.isConfirmable ||
                            viewModel.orderDetail!.isCancelable)
                        ? 100
                        : 32,
                  ),
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
                      const SizedBox(height: 36),
                    ],

                  ),
                ),
              ),
              if (viewModel.orderDetail!.isConfirmable ||
                  viewModel.orderDetail!.isCancelable)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          if (viewModel.orderDetail!.isCancelable)
                            Expanded(
                              child: SizedBox(
                                height: 53,
                                child: OutlinedButton(
                                  onPressed: viewModel.isCanceling
                                      ? null
                                      : _cancelOrder,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: viewModel.isCanceling
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.red,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'İptal Et',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          if (viewModel.orderDetail!.isCancelable &&
                              viewModel.orderDetail!.isConfirmable)
                            const SizedBox(width: 12),
                          if (viewModel.orderDetail!.isConfirmable)
                            Expanded(
                              child: SizedBox(
                                height: 53,
                                child: ElevatedButton(
                                  onPressed: viewModel.isConfirming
                                      ? null
                                      : _confirmOrder,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: viewModel.isConfirming
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Onayla ve İşleme Al',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
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
    
    // İlk ürünün tracking numarasını al
    final trackingNo = order.products.isNotEmpty 
        ? order.products.first.trackingNumber 
        : '';

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
                          onTap: () =>
                              _copyToClipboard(order.orderCode, 'Sipariş kodu'),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 16,
                            color: Colors.grey[400],
                          ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          // Etiket oluşturma butonu
          if (order.isCreateLabel && trackingNo.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            Consumer<OrderViewModel>(
              builder: (context, viewModel, child) {
                return InkWell(
                  onTap: viewModel.isCreatingLabel 
                      ? null 
                      : () => _createLabel(trackingNo),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.withOpacity(0.1),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 20,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kargo Etiketi Oluştur',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                              Text(
                                'Takip No: $trackingNo',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (viewModel.isCreatingLabel)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue,
                            ),
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.blue[600],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          // Tümünü Kargoya Ver butonu
          if (order.isMarkAllAsShipped) ...[
            const SizedBox(height: 12),
            if (!order.isCreateLabel || trackingNo.isEmpty)
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
            if (!order.isCreateLabel || trackingNo.isEmpty)
              const SizedBox(height: 12),
            Consumer<OrderViewModel>(
              builder: (context, viewModel, child) {
                return InkWell(
                  onTap: viewModel.isAddingCargo 
                      ? null 
                      : () => _addCargoAll(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.purple.withOpacity(0.1),
                      border: Border.all(color: Colors.purple.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping_rounded,
                          size: 20,
                          color: Colors.purple[700],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tümünü Kargoya Ver',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple[700],
                                ),
                              ),
                              Text(
                                'Tüm ürünleri tek seferde kargoya ver',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.purple[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (viewModel.isAddingCargo)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.purple,
                            ),
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.purple[600],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
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
              if (order.orderDiscount.isNotEmpty &&
                  order.orderDiscount != '0' &&
                  order.orderDiscount != '0,00 TL') ...[
                _buildSummaryRow(
                  'İndirim',
                  '-${order.orderDiscount}',
                  valueColor: Colors.green,
                ),
                const SizedBox(height: 12),
              ],
              _buildSummaryRow(
                'Toplam Tutar',
                order.orderAmount,
                isBold: true,
                valueColor: AppTheme.primaryColor,
                valueSize: 18,
              ),
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
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.orderDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.amber[900],
                        ),
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

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
    double? valueSize,
  }) {
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
          itemBuilder: (context, index) =>
              _buildProductCard(order.products[index]),
        ),
      ],
    );
  }

  Widget _buildProductCard(OrderProduct product) {
    final displayStatus = product.canceled
        ? 'İptal Edildi'
        : product.statusName;

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
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[400],
                      ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.currentQuantity} Adet',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
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
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              if (product.cargoAmount.isNotEmpty ||
                  product.cargoCompany.isNotEmpty) ...[
                const Spacer(),
                Icon(
                  Icons.local_shipping_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  product.cargoCompany,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          if (product.cargoCompany.isNotEmpty ||
              product.trackingNumber.isNotEmpty ||
              product.trackingURL.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _openTrackingUrl(product.trackingURL),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.withOpacity(0.05),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_searching_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kargo Takip: ${product.trackingNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Colors.grey,
                    ),
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
          // Ürünü Kargoya Ver butonu
          if (product.isAddCargoable) ...[
            const SizedBox(height: 12),
            Consumer<OrderViewModel>(
              builder: (context, viewModel, child) {
                return InkWell(
                  onTap: viewModel.isAddingCargo 
                      ? null 
                      : () => _addProductCargo(product),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.purple.withOpacity(0.1),
                      border: Border.all(color: Colors.purple.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping_rounded,
                          size: 16,
                          color: Colors.purple[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kargoya Ver',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple[700],
                            ),
                          ),
                        ),
                        if (viewModel.isAddingCargo)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.purple,
                            ),
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Colors.purple[600],
                          ),
                      ],
                    ),
                  ),
                );
              },
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address.address,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
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
                    _buildInvoiceRow(
                      'Vergi Dairesi',
                      address.taxAdministration,
                    ),
                ],
              ),
            ),
          ] else if (showInvoiceDetails &&
              !address.isCorporate &&
              address.identityNumber.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: _buildInvoiceRow(
                'TC Kimlik',
                _maskIdentityNumber(address.identityNumber),
              ),
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
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
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
              child: const Icon(
                Icons.description_outlined,
                color: Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Mesafeli Satış Sözleşmesi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey,
            ),

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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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

/// İptal ürün seçimi için bottom sheet
class _CancelOrderBottomSheet extends StatefulWidget {
  final List<OrderProduct> products;
  final int orderID;
  final List<OrderCancelType> cancelTypes;

  const _CancelOrderBottomSheet({
    required this.products,
    required this.orderID,
    required this.cancelTypes,
  });

  @override
  State<_CancelOrderBottomSheet> createState() => _CancelOrderBottomSheetState();
}

class _CancelOrderBottomSheetState extends State<_CancelOrderBottomSheet> {
  // Seçili ürünler: key = productID, value = {quantity, cancelType, cancelDesc}
  final Map<int, _CancelProductSelection> _selectedProducts = {};
  // Her ürün için açıklama controller'ı
  final Map<int, TextEditingController> _descControllers = {};

  @override
  void dispose() {
    for (var controller in _descControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _allSelectionsValid {
    return _selectedProducts.values.every((s) => s.isValid);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
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
                    'Ürün İptal Et',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: widget.products.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = widget.products[index];
                  final isSelected = _selectedProducts.containsKey(product.productID);
                  final selection = _selectedProducts[product.productID];

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.red.withOpacity(0.3) : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: isSelected,
                              activeColor: Colors.red,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    final firstType = widget.cancelTypes.first;
                                    _descControllers[product.productID] = TextEditingController();
                                    _selectedProducts[product.productID] = _CancelProductSelection(
                                      proID: product.productID,
                                      quantity: product.currentQuantity,
                                      maxQuantity: product.currentQuantity,
                                      cancelType: firstType.typeID,
                                      cancelDesc: firstType.typeName,
                                    );
                                  } else {
                                    _descControllers[product.productID]?.dispose();
                                    _descControllers.remove(product.productID);
                                    _selectedProducts.remove(product.productID);
                                  }
                                });
                              },
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.productImage,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[100],
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
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
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (product.variants.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      product.variants,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    'Mevcut: ${product.currentQuantity} Adet',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          // Miktar seçimi
                          Row(
                            children: [
                              const Text(
                                'İptal Miktarı:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 18),
                                      onPressed: selection!.quantity > 1
                                          ? () {
                                              setState(() {
                                                _selectedProducts[product.productID] =
                                                    selection.copyWith(
                                                        quantity: selection.quantity - 1);
                                              });
                                            }
                                          : null,
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        '${selection.quantity}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 18),
                                      onPressed: selection.quantity < selection.maxQuantity
                                          ? () {
                                              setState(() {
                                                _selectedProducts[product.productID] =
                                                    selection.copyWith(
                                                        quantity: selection.quantity + 1);
                                              });
                                            }
                                          : null,
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // İptal nedeni
                          const Text(
                            'İptal Nedeni:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selection.cancelType,
                                isExpanded: true,
                                items: widget.cancelTypes.map((type) {
                                  return DropdownMenuItem<int>(
                                    value: type.typeID,
                                    child: Text(type.typeName),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    final type = widget.cancelTypes.firstWhere((t) => t.typeID == value);
                                    setState(() {
                                      _selectedProducts[product.productID] = selection.copyWith(
                                        cancelType: value,
                                        cancelDesc: type.typeName,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Açıklama alanı
                          Text(
                            selection.cancelType == 13
                                ? 'Açıklama (Zorunlu):'
                                : 'Açıklama (İsteğe Bağlı):',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: selection.cancelType == 13 && selection.customDesc.trim().isEmpty
                                  ? Colors.red
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descControllers[product.productID],
                            decoration: InputDecoration(
                              hintText: 'İptal nedenini açıklayın...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: selection.cancelType == 13 && selection.customDesc.trim().isEmpty
                                      ? Colors.red.shade300
                                      : Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: selection.cancelType == 13
                                      ? Colors.red
                                      : AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            maxLines: 2,
                            onChanged: (value) {
                              setState(() {
                                _selectedProducts[product.productID] = selection.copyWith(
                                  customDesc: value,
                                );
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 53,
                  child: ElevatedButton(
                    onPressed: _selectedProducts.isEmpty || !_allSelectionsValid
                        ? null
                        : () {
                            final cancelProducts = _selectedProducts.values
                                .map((s) => CancelProduct(
                                      proID: s.proID,
                                      quantity: s.quantity,
                                      cancelType: s.cancelType,
                                      cancelDesc: s.finalDesc,
                                    ))
                                .toList();
                            Navigator.pop(context, cancelProducts);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _selectedProducts.isEmpty
                          ? 'Ürün Seçin'
                          : '${_selectedProducts.length} Ürünü İptal Et',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// İptal ürün seçimi için yardımcı model
class _CancelProductSelection {
  final int proID;
  final int quantity;
  final int maxQuantity;
  final int cancelType;
  final String cancelDesc;
  final String customDesc;

  _CancelProductSelection({
    required this.proID,
    required this.quantity,
    required this.maxQuantity,
    required this.cancelType,
    required this.cancelDesc,
    this.customDesc = '',
  });

  _CancelProductSelection copyWith({
    int? proID,
    int? quantity,
    int? maxQuantity,
    int? cancelType,
    String? cancelDesc,
    String? customDesc,
  }) {
    return _CancelProductSelection(
      proID: proID ?? this.proID,
      quantity: quantity ?? this.quantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      cancelType: cancelType ?? this.cancelType,
      cancelDesc: cancelDesc ?? this.cancelDesc,
      customDesc: customDesc ?? this.customDesc,
    );
  }

  /// "Diğer" seçildiğinde customDesc zorunlu
  bool get isValid {
    // typeID 13 = Diğer
    if (cancelType == 13) {
      return customDesc.trim().isNotEmpty;
    }
    return true;
  }

  /// API'ye gönderilecek açıklama
  String get finalDesc {
    if (customDesc.trim().isNotEmpty) {
      return customDesc.trim();
    }
    return cancelDesc;
  }
}
