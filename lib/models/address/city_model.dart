class CityModel {
  final int cityNO;
  final String cityName;

  CityModel({
    required this.cityNO,
    required this.cityName,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      cityNO: json['cityNO'] as int,
      cityName: json['cityName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityNO': cityNO,
      'cityName': cityName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityModel &&
          runtimeType == other.runtimeType &&
          cityNO == other.cityNO;

  @override
  int get hashCode => cityNO.hashCode;
}
