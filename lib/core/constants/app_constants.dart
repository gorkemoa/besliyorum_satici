class AppConstants {
  static const String apiUrl = 'https://api.besliyorum.com/sp/v1.0.0/';

  // Basic Auth Credentials
  static const String basicAuthUsername = 'SP1VAhW2ICWHJN2nlvp9K5ycGoyMBM';
  static const String basicAuthPassword = 'vRP4hTJsqmjtmkI17I1EVpPH57Edl0';
}

class Endpoints {
  static const String login = 'service/auth/login';

  // Order Endpoints
  static const String orderList = 'service/user/account/order/list';
  static const String orderDetail = 'service/user/account/order/detail';
}
