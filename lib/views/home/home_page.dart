import 'package:besliyorum_satici/views/notification/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/notification_viewmodel.dart';
import 'package:besliyorum_satici/models/home/home_model.dart';
import '../auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // State'i sessizce temizle (notifyListeners çağırmadan)
    Provider.of<HomeViewModel>(context, listen: false).resetState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final notificationViewModel = Provider.of<NotificationViewModel>(context, listen: false);

    final userId = authViewModel.loginResponse?.data?.userID;
    final token = authViewModel.loginResponse?.data?.token;

    if (userId != null && token != null) {
      await Future.wait([
        homeViewModel.getUserAccount(userId, token),
        notificationViewModel.getNotifications(token),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/Icons/bes-favicon.png',
            width: 35,
            height: 35,
            fit: BoxFit.contain,
          ),
          onPressed: () async { },
        ),
        actions: [
          Consumer<NotificationViewModel>(
            builder: (context, notificationViewModel, child) {
              final unreadCount = notificationViewModel.unreadCount;
              return IconButton(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                  child: Image.asset(
                    'assets/Icons/bildirim.png',
                    width: 25,
                    height: 25,
                    fit: BoxFit.contain,
                    color: Colors.grey,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsPage()),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            if (viewModel.errorMessage == '403_LOGOUT') {
              // Schedule navigation after build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              });
              return const SizedBox.shrink(); // Return empty while redirecting
            }
            return Center(child: Text('Error: ${viewModel.errorMessage}'));
          }

          final data = viewModel.homeData;
          if (data == null) {
            return const Center(child: Text('No data available'));
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(data),
                  const SizedBox(height: 24),
                  _buildStatisticsGrid(data.statistics),
                  const SizedBox(height: 24),
                  _buildOrderSummary(data.statistics),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(HomeData data) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            backgroundImage: data.storeLogo.isNotEmpty
                ? NetworkImage(data.storeLogo)
                : null,
            child: data.storeLogo.isEmpty
                ? const Icon(Icons.store, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.storeName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.userFullname,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: AppTheme.primaryColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  data.storePoint,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(Statistics stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Toplam Ürün',
          stats.totalSellerProducts.toString(),
          Icons.inventory_2,
        ),
        _buildStatCard(
          'Bekleyen Sipariş',
          stats.pedingOrders.toString(),
          Icons.pending_actions,
        ),
        _buildStatCard(
          'Kargo',
          stats.truckOrders.toString(),
          Icons.local_shipping,
        ),
        _buildStatCard(
          'Gelecek Ödeme',
          stats.futurePayAmount,
          Icons.account_balance_wallet,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(Statistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sipariş Özeti',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildOrderSummaryCard('Bugün', stats.todayOrder),
        const SizedBox(height: 12),
        _buildOrderSummaryCard('Bu Hafta', stats.weekOrder),
        const SizedBox(height: 12),
        _buildOrderSummaryCard('Bu Ay', stats.monthOrder),
      ],
    );
  }

  Widget _buildOrderSummaryCard(String title, OrderStats orderStats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Row(
            children: [
              Text(
                '${orderStats.totalOrder} Sipariş',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(width: 12),
              Container(height: 20, width: 1, color: Colors.grey[300]),
              const SizedBox(width: 12),
              Text(
                orderStats.totalAmount,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
