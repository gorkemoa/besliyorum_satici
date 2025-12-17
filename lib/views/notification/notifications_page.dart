import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../models/notification/notification_model.dart';
import '../order/order_detail_page.dart';
import '../auth/login_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  void _loadNotifications() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final notificationViewModel = Provider.of<NotificationViewModel>(
      context,
      listen: false,
    );

    final token = authViewModel.loginResponse?.data?.token;

    if (token != null) {
      notificationViewModel.getNotifications(token);
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final notificationViewModel = Provider.of<NotificationViewModel>(
      context,
      listen: false,
    );
    final token = authViewModel.loginResponse?.data?.token;

    // Bildirimi okundu olarak işaretle
    if (token != null && !notification.isRead) {
      notificationViewModel.markAsRead(token, notification.id);
    }

    switch (notification.navigationType) {
      case NotificationNavigationType.orderDetail:
        // typeID sipariş ID'si olarak kullanılıyor
        if (notification.typeID > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderDetailPage(orderID: notification.typeID),
            ),
          );
        }
        break;
      case NotificationNavigationType.externalUrl:
        _openUrl(notification.url);
        break;
      case NotificationNavigationType.none:
        // Bildirimi sadece okundu olarak işaretle (yukarıda yapıldı)
        break;
    }
  }

  Future<void> _markAllAsRead() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final notificationViewModel = Provider.of<NotificationViewModel>(
      context,
      listen: false,
    );
    final token = authViewModel.loginResponse?.data?.token;

    if (token != null) {
      final success = await notificationViewModel.markAllAsRead(token);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tüm bildirimler okundu olarak işaretlendi'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    }
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link açılamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        title: const Text(
          'Bildirimler',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Consumer<NotificationViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.unreadCount > 0) {
                return TextButton(
                  onPressed: _markAllAsRead,
                  child: Text(
                    'Tümünü Oku',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          // Logout kontrolü
          if (viewModel.errorMessage == '403_LOGOUT') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewModel.resetState();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            });
            return const SizedBox.shrink();
          }

          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (viewModel.errorMessage != null) {
            return _buildErrorWidget(viewModel.errorMessage!);
          }

          if (viewModel.notifications.isEmpty) {
            return _buildEmptyWidget(viewModel.emptyMessage);
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadNotifications();
            },
            color: AppTheme.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.notifications.length,
              itemBuilder: (context, index) {
                final notification = viewModel.notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    final hasAction =
        notification.navigationType != NotificationNavigationType.none;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: notification.isRead
            ? null
            : Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: hasAction ? () => _handleNotificationTap(notification) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bildirim resmi
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: notification.image.isNotEmpty
                      ? Image.network(
                          notification.image,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey[200],
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              ),
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Bildirim içeriği
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification.createDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                          if (hasAction)
                            Row(
                              children: [
                                Text(
                                  _getActionText(notification),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _getActionIcon(notification),
                                  size: 14,
                                  color: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getActionText(NotificationItem notification) {
    switch (notification.navigationType) {
      case NotificationNavigationType.orderDetail:
        return 'Siparişi Gör';
      case NotificationNavigationType.externalUrl:
        return 'Linke Git';
      case NotificationNavigationType.none:
        return '';
    }
  }

  IconData _getActionIcon(NotificationItem notification) {
    switch (notification.navigationType) {
      case NotificationNavigationType.orderDetail:
        return Icons.arrow_forward_ios;
      case NotificationNavigationType.externalUrl:
        return Icons.open_in_new;
      case NotificationNavigationType.none:
        return Icons.arrow_forward_ios;
    }
  }

  Widget _buildEmptyWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              message.isNotEmpty ? message : 'Henüz bildiriminiz yok',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Bildirimler yüklenirken bir hata oluştu',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
