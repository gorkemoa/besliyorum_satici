class DistrictModel {
  final int districtNO;
  final String districtName;

  DistrictModel({
    required this.districtNO,
    required this.districtName,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      districtNO: json['districtNO'] as int,
      districtName: json['districtName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'districtNO': districtNO,
      'districtName': districtName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistrictModel &&
          runtimeType == other.runtimeType &&
          districtNO == other.districtNO;

  @override
  int get hashCode => districtNO.hashCode;
}
