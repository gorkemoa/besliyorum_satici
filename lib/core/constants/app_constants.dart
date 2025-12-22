class AppConstants {
  static const String apiUrl = 'https://api.besliyorum.com/sp/v1.0.0/';

  // Basic Auth Credentials
  static const String basicAuthUsername = 'SP1VAhW2ICWHJN2nlvp9K5ycGoyMBM';
  static const String basicAuthPassword = 'vRP4hTJsqmjtmkI17I1EVpPH57Edl0';
}

class Endpoints {
  static const String login = 'service/auth/login';
  static const String register = 'service/auth/register';

  // Location Endpoints
  static const String cities = 'service/general/general/cities/all';
  static const String districts = 'service/general/general'; // /{cityNO}/districts
  static const String neighborhoods = 'service/general/general'; // /{districtNO}/neighbourhood

  // Order Endpoints
  static const String orderList = 'service/user/account/order/list';
  static const String orderDetail = 'service/user/account/order/detail';
  static const String orderStatuses = 'service/general/general/orderStatuses';
  static const String orderConfirm = 'service/user/account/order/orderConfirm';
  static const String orderCancel = 'service/user/account/order/orderCancel';
  static const String orderCancelTypes = 'service/general/general/orderCancelTypes';
  static const String createLabel = 'service/user/account/order/orderCreateLabel';
  static const String addOrderCargo = 'service/user/account/order/addOrderCargo';

  // Notification Endpoints
  static const String notifications = 'service/user/account/notifications';
  static const String notificationRead = 'service/user/account/notification/read';
  static const String notificationAllRead = 'service/user/account/notification/allRead';

  // Contract/Policy Endpoints
  static const String sellerPolicy = 'service/general/general/contracts/sellerPolicy';
  static const String kvkkPolicy = 'service/general/general/contracts/kvkkPolicy';
  static const String iyzicoPolicy = 'https://www.iyzico.com/pazaryeri-satici-anlasma';
}
