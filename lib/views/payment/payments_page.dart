import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/payment_viewmodel.dart';
import '../../models/payment/payment_model.dart';
import '../auth/login_page.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final paymentViewModel =
        Provider.of<PaymentViewModel>(context, listen: false);
    paymentViewModel.resetState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPayments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPayments() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final paymentViewModel =
        Provider.of<PaymentViewModel>(context, listen: false);

    final token = authViewModel.loginResponse?.data?.token;

    if (token != null) {
      paymentViewModel.getPayments(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödemeler'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Bekleyen Ödemeler'),
            Tab(text: 'Geçmiş Ödemeler'),
          ],
        ),
      ),
      body: Consumer<PaymentViewModel>(
        builder: (context, viewModel, child) {
          // 403 hatası kontrolü
          if (viewModel.errorMessage == '403_LOGOUT') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            });
            return const SizedBox.shrink();
          }

          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage!,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPayments,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Bekleyen (Gelecek) Ödemeler
              _buildPaymentList(
                payments: viewModel.futurePayments,
                totalAmount: viewModel.futurePaymentsTotalAmount,
                totalItems: viewModel.futurePaymentsTotalItems,
                emptyMessage: 'Bekleyen ödemeniz bulunmamaktadır.',
                isFuture: true,
              ),
              // Geçmiş Ödemeler
              _buildPaymentList(
                payments: viewModel.pastPayments,
                totalAmount: viewModel.pastPaymentsTotalAmount,
                totalItems: viewModel.pastPaymentsTotalItems,
                emptyMessage: 'Geçmiş ödemeniz bulunmamaktadır.',
                isFuture: false,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentList({
    required List<Payment> payments,
    required String totalAmount,
    required int totalItems,
    required String emptyMessage,
    required bool isFuture,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadPayments();
      },
      child: Column(
        children: [
          // Özet kartı
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isFuture
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFuture
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFuture ? 'Toplam Bekleyen' : 'Toplam Ödenen',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalAmount,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isFuture ? Colors.orange[700] : Colors.green[700],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isFuture ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalItems Ödeme',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Ödeme listesi
          Expanded(
            child: payments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          emptyMessage,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return _buildPaymentCard(payment);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: payment.isPaid
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        payment.isPaid
                            ? Icons.check_circle_outline
                            : Icons.schedule,
                        color: payment.isPaid ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sipariş #${payment.orderID}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          payment.payDate,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      payment.payAmount,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: payment.isPaid ? Colors.green : Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 2),
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
                        'Komisyon: ${payment.commissionRate}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: payment.isPaid
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                payment.isPaid ? 'Ödendi' : 'Beklemede',
                style: TextStyle(
                  color: payment.isPaid ? Colors.green[700] : Colors.orange[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
