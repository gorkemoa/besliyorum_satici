class DeleteUserRequestModel {
  final String userToken;

  DeleteUserRequestModel({
    required this.userToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
    };
  }
}

class DeleteUserResponseModel {
  final bool error;
  final bool success;
  final String? message;
  final bool code200;
  final String? errorMessage;

  DeleteUserResponseModel({
    required this.error,
    required this.success,
    this.message,
    required this.code200,
    this.errorMessage,
  });

  factory DeleteUserResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteUserResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      message: json['message'],
      code200: json['200'] == 'OK' || json['200'] == true,
      errorMessage: json['error_message'],
    );
  }
}
