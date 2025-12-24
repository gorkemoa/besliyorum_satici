class AddAddressRequest {
  final String userToken;
  final int? addressID;
  final int addressType;
  final int addressCity;
  final int addressDistrict;
  final int addressNeighborhood;
  final String address;

  AddAddressRequest({
    required this.userToken,
    this.addressID,
    required this.addressType,
    required this.addressCity,
    required this.addressDistrict,
    required this.addressNeighborhood,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'userToken': userToken,
      'addressType': addressType,
      'addressCity': addressCity,
      'addressDistrict': addressDistrict,
      'addressNeighborhood': addressNeighborhood,
      'address': address,
    };
    if (addressID != null) {
      map['addressID'] = addressID;
    }
    return map;
  }
}
