class UpdateUserRequestModel {
  final String userToken;
  final String userFirstname;
  final String userLastname;
  final String userEmail;
  final String userPhone;
  final String userBirthday;
  final String userGender;
  final String profilePhoto;

  UpdateUserRequestModel({
    required this.userToken,
    required this.userFirstname,
    required this.userLastname,
    required this.userEmail,
    required this.userPhone,
    required this.userBirthday,
    required this.userGender,
    this.profilePhoto = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'userFirstname': userFirstname,
      'userLastname': userLastname,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userBirthday': userBirthday,
      'userGender': userGender,
      'profilePhoto': profilePhoto,
    };
  }
}

class UpdateUserResponseModel {
  final bool error;
  final bool success;
  final String? code200;
  final String? errorMessage;

  UpdateUserResponseModel({
    required this.error,
    required this.success,
    this.code200,
    this.errorMessage,
  });

  factory UpdateUserResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateUserResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      code200: json['200'],
      errorMessage: json['error_message'],
    );
  }
}
