class RegisterRequestModel {
  final String userFirstname;
  final String userLastname;
  final String userEmail;
  final String userPhone;
  final String storeName;
  final int storeType; // 1- Şahıs Şirketi, 2 - Şirket
  final int storeCity;
  final int storeDistrict;
  final int storeNeighborhood;
  final String storeAddress;
  final String storeTaxno; // Şahıs: 11 hane TC, Şirket: 10 hane Vergi No
  final int isPolicy;
  final int isIyzicoPolicy;
  final int isKvkkPolicy;

  RegisterRequestModel({
    required this.userFirstname,
    required this.userLastname,
    required this.userEmail,
    required this.userPhone,
    required this.storeName,
    required this.storeType,
    required this.storeCity,
    required this.storeDistrict,
    required this.storeNeighborhood,
    required this.storeAddress,
    required this.storeTaxno,
    required this.isPolicy,
    required this.isIyzicoPolicy,
    required this.isKvkkPolicy,
  });

  Map<String, dynamic> toJson() {
    return {
      'userFirstname': userFirstname,
      'userLatname': userLastname, // API'de userLatname olarak gidiyor
      'userEmail': userEmail,
      'userPhone': userPhone,
      'storeName': storeName,
      'storeType': storeType,
      'storeCity': storeCity,
      'storeDistrict': storeDistrict,
      'storeNeighborhood': storeNeighborhood,
      'storeAddress': storeAddress,
      'storeTaxno': storeTaxno,
      'isPolicy': isPolicy,
      'isIyzicoPolicy': isIyzicoPolicy,
      'isKvkkPolicy': isKvkkPolicy,
    };
  }
}

class RegisterResponseModel {
  final bool error;
  final bool success;
  final String? errorMessage;
  final String? code200;
  final String? code417;

  RegisterResponseModel({
    required this.error,
    required this.success,
    this.errorMessage,
    this.code200,
    this.code417,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      errorMessage: json['error_message'],
      code200: json['200'],
      code417: json['417'],
    );
  }

  String get message {
    if (success && code200 != null) {
      return code200!;
    }
    if (errorMessage != null) {
      return errorMessage!;
    }
    if (code417 != null) {
      return code417!;
    }
    return 'Bilinmeyen bir hata oluştu.';
  }
}
