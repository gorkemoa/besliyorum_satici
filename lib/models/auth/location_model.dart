class CityModel {
  final int id;
  final String name;

  CityModel({required this.id, required this.name});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(id: json['cityNO'] ?? 0, name: json['cityName'] ?? '');
  }
}

class DistrictModel {
  final int id;
  final String name;

  DistrictModel({required this.id, required this.name});

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['districtNO'] ?? 0,
      name: json['districtName'] ?? '',
    );
  }
}

class NeighborhoodModel {
  final int id;
  final String name;

  NeighborhoodModel({required this.id, required this.name});

  factory NeighborhoodModel.fromJson(Map<String, dynamic> json) {
    return NeighborhoodModel(
      id: json['neighbourhoodNo'] ?? 0,
      name: json['neighbourhoodName'] ?? '',
    );
  }
}

class LocationResponseModel<T> {
  final bool error;
  final bool success;
  final List<T> data;
  final String? errorMessage;

  LocationResponseModel({
    required this.error,
    required this.success,
    required this.data,
    this.errorMessage,
  });

  factory LocationResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
    String dataKey,
  ) {
    List<T> dataList = [];
    if (json['data'] != null && json['data'][dataKey] != null) {
      dataList = (json['data'][dataKey] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList();
    }

    return LocationResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: dataList,
      errorMessage: json['error_message'],
    );
  }
}
