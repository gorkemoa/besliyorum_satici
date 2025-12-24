class UpdateAddressRequest {
  final String userToken;
  final int addressID;
  final int addressCity;
  final int addressDistrict;
  final int addressNeighborhood;
  final String address;

  UpdateAddressRequest({
    required this.userToken,
    required this.addressID,
    required this.addressCity,
    required this.addressDistrict,
    required this.addressNeighborhood,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'addressID': addressID,
      'addressCity': addressCity,
      'addressDistrict': addressDistrict,
      'addressNeighborhood': addressNeighborhood,
      'address': address,
    };
  }
}
