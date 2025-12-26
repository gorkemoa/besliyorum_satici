import 'address_model.dart';

class GetAddressesResponse {
  final bool error;
  final bool success;
  final AddressesData data;
  final String message;

  GetAddressesResponse({
    required this.error,
    required this.success,
    required this.data,
    required this.message,
  });

  factory GetAddressesResponse.fromJson(Map<String, dynamic> json) {
    return GetAddressesResponse(
      error: json['error'] as bool,
      success: json['success'] as bool,
      data: AddressesData.fromJson(json['data'] as Map<String, dynamic>),
      message: json['200'] as String? ?? '',
    );
  }
}

class AddressesData {
  final bool isAddressComplete;
  final List<String> missingAddressTypes;
  final List<AddressModel> addresses;

  AddressesData({
    required this.isAddressComplete,
    required this.missingAddressTypes,
    required this.addresses,
  });

  factory AddressesData.fromJson(Map<String, dynamic> json) {
    return AddressesData(
      isAddressComplete: json['isAddressComplete'] as bool,
      missingAddressTypes: (json['missingAddressTypes'] as List)
          .map((item) => item as String)
          .toList(),
      addresses: (json['addresses'] as List)
          .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
