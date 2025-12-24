class AddressModel {
  final int addressID;
  final String addressType;
  final String cityName;
  final String districtName;
  final String address;
  final bool isDefault;

  AddressModel({
    required this.addressID,
    required this.addressType,
    required this.cityName,
    required this.districtName,
    required this.address,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressID: json['addressID'] as int,
      addressType: json['addressType'] as String,
      cityName: json['cityName'] as String,
      districtName: json['districtName'] as String,
      address: json['address'] as String,
      isDefault: json['isDefault'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressID': addressID,
      'addressType': addressType,
      'cityName': cityName,
      'districtName': districtName,
      'address': address,
      'isDefault': isDefault,
    };
  }
}
