class AppConstants {
  static const String apiUrl = 'https://api.besliyorum.com/sp/v1.0.0/';

  // Basic Auth Credentials
  static const String basicAuthUsername = 'SP1VAhW2ICWHJN2nlvp9K5ycGoyMBM';
  static const String basicAuthPassword = 'vRP4hTJsqmjtmkI17I1EVpPH57Edl0';
}

class Endpoints {
  static const String login = 'service/auth/login';
  static const String register = 'service/auth/register';
  static const String storeControl = 'service/auth/register/storeControl';

  // Location Endpoints
  static const String cities = 'service/general/general/cities/all';
  static const String districts =
      'service/general/general'; // /{cityNO}/districts
  static const String neighborhoods =
      'service/general/general'; // /{districtNO}/neighbourhood

  // Order Endpoints
  static const String orderList = 'service/user/account/order/list';
  static const String orderDetail = 'service/user/account/order/detail';
  static const String orderStatuses = 'service/general/general/orderStatuses';
  static const String orderConfirm = 'service/user/account/order/orderConfirm';
  static const String orderCancel = 'service/user/account/order/orderCancel';
  static const String orderCancelTypes =
      'service/general/general/orderCancelTypes';
  static const String createLabel =
      'service/user/account/order/orderCreateLabel';
  static const String addOrderCargo =
      'service/user/account/order/addOrderCargo';

  // Notification Endpoints
  static const String notifications = 'service/user/account/notifications';
  static const String notificationRead =
      'service/user/account/notification/read';
  static const String notificationAllRead =
      'service/user/account/notification/allRead';

  // Contract/Policy Endpoints
  static const String sellerPolicy =
      'service/general/general/contracts/sellerPolicy';
  static const String kvkkPolicy =
      'service/general/general/contracts/kvkkPolicy';
  static const String iyzicoPolicy =
      'https://www.iyzico.com/pazaryeri-satici-anlasma';
  static const String documents = 'service/user/account/documents/list';

  // Product Endpoints
  static const String sellerProducts =
      'service/user/account/products/sellerProducts';
  static const String catalogProducts =
      'service/user/account/products/catalogProducts';
  static const String categories = 'service/user/account/products/categories';
  static const String productDetail =
      'service/user/account/products/productDetail';
  static const String sellProduct = 'service/user/account/products/sellProduct';
  static const String sellUpdateProduct =
      'service/user/account/products/sellUpdateProduct';

  // Payment Endpoints
  static const String paymentList = 'service/user/account/payments/list';

  // User Endpoints
  static const String updateUser = 'service/user/account/update';
  static const String updatePassword = 'service/user/account/updatePassword';
  static const String deleteUser = 'service/user/account/delete';

  // Address Endpoints
  static const String addressList = 'service/user/account/address/list';
  static const String addressAdd = 'service/user/account/address/add';
  static const String addressUpdate = 'service/user/account/address/update';
  static const String addressTypes = 'service/general/general/addressTypes';
}
