class HomeResponseModel {
  final bool error;
  final bool success;
  final HomeData? data;
  final String? code200;

  HomeResponseModel({
    required this.error,
    required this.success,
    this.data,
    this.code200,
  });

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    return HomeResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? HomeData.fromJson(json['data']) : null,
      code200: json['200'],
    );
  }
}

class HomeData {
  final int storeID;
  final int userID;
  final String username;
  final String userFirstname;
  final String userLastname;
  final String userFullname;
  final String userEmail;
  final String userBirthday;
  final String userPhone;
  final String storeName;
  final String storePoint;
  final bool isActive;
  final bool isDeleted;
  final String userGender;
  final String userToken;
  final String registerDate;
  final String platform;
  final String userVersion;
  final String iOSVersion;
  final String androidVersion;
  final String profilePhoto;
  final String storeLogo;
  final Statistics statistics;

  HomeData({
    required this.storeID,
    required this.userID,
    required this.username,
    required this.userFirstname,
    required this.userLastname,
    required this.userFullname,
    required this.userEmail,
    required this.userBirthday,
    required this.userPhone,
    required this.storeName,
    required this.storePoint,
    required this.isActive,
    required this.isDeleted,
    required this.userGender,
    required this.userToken,
    required this.registerDate,
    required this.platform,
    required this.userVersion,
    required this.iOSVersion,
    required this.androidVersion,
    required this.profilePhoto,
    required this.storeLogo,
    required this.statistics,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      storeID: json['storeID'],
      userID: json['userID'],
      username: json['username'],
      userFirstname: json['userFirstname'],
      userLastname: json['userLastname'],
      userFullname: json['userFullname'],
      userEmail: json['userEmail'],
      userBirthday: json['userBirthday'] ?? '',
      userPhone: json['userPhone'],
      storeName: json['storeName'],
      storePoint: json['storePoint'],
      isActive: json['isActive'],
      isDeleted: json['isDeleted'],
      userGender: json['userGender'],
      userToken: json['userToken'],
      registerDate: json['registerDate'],
      platform: json['platform'],
      userVersion: json['userVersion'],
      iOSVersion: json['iOSVersion'],
      androidVersion: json['androidVersion'],
      profilePhoto: json['profilePhoto'] ?? '',
      storeLogo: json['storeLogo'],
      statistics: Statistics.fromJson(json['statistics']),
    );
  }
}

class Statistics {
  final int totalSellerProducts;
  final int truckOrders;
  final int pedingOrders;
  final OrderStats todayOrder;
  final OrderStats weekOrder;
  final OrderStats monthOrder;
  final String futurePayAmount;

  Statistics({
    required this.totalSellerProducts,
    required this.truckOrders,
    required this.pedingOrders,
    required this.todayOrder,
    required this.weekOrder,
    required this.monthOrder,
    required this.futurePayAmount,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalSellerProducts: json['totalSellerProducts'],
      truckOrders: json['truckOrders'],
      pedingOrders: json['pedingOrders'],
      todayOrder: OrderStats.fromJson(json['todayOrder']),
      weekOrder: OrderStats.fromJson(json['weekOrder']),
      monthOrder: OrderStats.fromJson(json['monthOrder']),
      futurePayAmount: json['futurePayAmount'],
    );
  }
}

class OrderStats {
  final int totalOrder;
  final String totalAmount;

  OrderStats({required this.totalOrder, required this.totalAmount});

  factory OrderStats.fromJson(Map<String, dynamic> json) {
    return OrderStats(
      totalOrder: json['totalOrder'],
      totalAmount: json['totalAmount'],
    );
  }
}
