class NotificationResponseModel {
  final bool error;
  final bool success;
  final NotificationData? data;
  final String? code200;

  NotificationResponseModel({
    required this.error,
    required this.success,
    this.data,
    this.code200,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null
          ? NotificationData.fromJson(json['data'])
          : null,
      code200: json['200'],
    );
  }
}

class NotificationData {
  final int totalItems;
  final String emptyMessage;
  final List<NotificationItem> notifications;

  NotificationData({
    required this.totalItems,
    required this.emptyMessage,
    required this.notifications,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      totalItems: json['totalItems'] ?? 0,
      emptyMessage: json['emptyMessage'] ?? '',
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class NotificationItem {
  final int id;
  final String title;
  final String body;
  final String type;
  final int typeID;
  final String url;
  final String image;
  final bool isRead;
  final String createDate;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.typeID,
    required this.url,
    required this.image,
    required this.isRead,
    required this.createDate,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      typeID: json['typeID'] ?? -1,
      url: json['url'] ?? '',
      image: json['image'] ?? '',
      isRead: json['isRead'] ?? false,
      createDate: json['create_date'] ?? '',
    );
  }

  /// Bildirim türüne göre navigasyon hedefini belirler
  NotificationNavigationType get navigationType {
    switch (type) {
      case 'order_sp_created':
      case 'return_sp_request':
        return NotificationNavigationType.orderDetail;
      default:
        if (typeID == -1 && url.isNotEmpty) {
          return NotificationNavigationType.externalUrl;
        }
        return NotificationNavigationType.none;
    }
  }

  /// Kopyalama metodu - isRead gibi değerleri güncellemek için
  NotificationItem copyWith({
    int? id,
    String? title,
    String? body,
    String? type,
    int? typeID,
    String? url,
    String? image,
    bool? isRead,
    String? createDate,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      typeID: typeID ?? this.typeID,
      url: url ?? this.url,
      image: image ?? this.image,
      isRead: isRead ?? this.isRead,
      createDate: createDate ?? this.createDate,
    );
  }
}

enum NotificationNavigationType {
  orderDetail,
  externalUrl,
  none,
}
