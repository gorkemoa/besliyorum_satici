class NeighborhoodModel {
  final int neighbourhoodNo;
  final String neighbourhoodName;

  NeighborhoodModel({
    required this.neighbourhoodNo,
    required this.neighbourhoodName,
  });

  factory NeighborhoodModel.fromJson(Map<String, dynamic> json) {
    return NeighborhoodModel(
      neighbourhoodNo: json['neighbourhoodNo'] as int,
      neighbourhoodName: json['neighbourhoodName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'neighbourhoodNo': neighbourhoodNo,
      'neighbourhoodName': neighbourhoodName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NeighborhoodModel &&
          runtimeType == other.runtimeType &&
          neighbourhoodNo == other.neighbourhoodNo;

  @override
  int get hashCode => neighbourhoodNo.hashCode;
}
