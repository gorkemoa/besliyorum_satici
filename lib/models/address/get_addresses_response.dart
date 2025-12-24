import 'address_model.dart';

class GetAddressesResponse {
  final bool error;
  final bool success;
  final List<AddressModel> data;
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
      data: (json['data'] as List)
          .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      message: json['200'] as String? ?? '',
    );
  }
}
