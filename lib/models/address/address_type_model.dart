class AddressTypeModel {
  final int typeID;
  final String typeName;

  AddressTypeModel({
    required this.typeID,
    required this.typeName,
  });

  factory AddressTypeModel.fromJson(Map<String, dynamic> json) {
    return AddressTypeModel(
      typeID: json['typeID'] as int,
      typeName: json['typeName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'typeID': typeID,
      'typeName': typeName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressTypeModel &&
          runtimeType == other.runtimeType &&
          typeID == other.typeID;

  @override
  int get hashCode => typeID.hashCode;
}
