class UpdatePasswordRequestModel {
  final String userToken;
  final String currentPassword;
  final String password;
  final String passwordAgain;

  UpdatePasswordRequestModel({
    required this.userToken,
    required this.currentPassword,
    required this.password,
    required this.passwordAgain,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'currentPassword': currentPassword,
      'password': password,
      'passwordAgain': passwordAgain,
    };
  }
}

class UpdatePasswordResponseModel {
  final bool error;
  final bool success;
  final String? message;
  final bool code200;
  final String? errorMessage;

  UpdatePasswordResponseModel({
    required this.error,
    required this.success,
    this.message,
    required this.code200,
    this.errorMessage,
  });

  factory UpdatePasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdatePasswordResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      message: json['message'],
      code200: json['200'] == 'OK' || json['200'] == true,
      errorMessage: json['error_message'],
    );
  }
}
