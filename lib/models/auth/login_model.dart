class LoginRequestModel {
  final String userName;
  final String userPassword;

  LoginRequestModel({required this.userName, required this.userPassword});

  Map<String, dynamic> toJson() {
    return {'userName': userName, 'userPassword': userPassword};
  }
}

class LoginResponseModel {
  final bool error;
  final bool success;
  final LoginData? data;
  final String? errorMessage;
  final String? code200;
  final String? code417;

  LoginResponseModel({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
    this.code200,
    this.code417,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      errorMessage: json['error_message'],
      code200: json['200'],
      code417: json['417'],
    );
  }
}

class LoginData {
  final int userID;
  final String token;

  LoginData({required this.userID, required this.token});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(userID: json['userID'], token: json['token']);
  }
}
