class CategoryResponseModel {
  final bool error;
  final bool success;
  final List<DetailedCategory>? data;

  CategoryResponseModel({
    required this.error,
    required this.success,
    this.data,
  });

  factory CategoryResponseModel.fromJson(Map<String, dynamic> json) {
    return CategoryResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List).map((i) => DetailedCategory.fromJson(i)).toList()
          : null,
    );
  }
}

class DetailedCategory {
  final int catID;
  final String catName;
  final String catImage;
  final List<DetailedCategory> subCategories;

  DetailedCategory({
    required this.catID,
    required this.catName,
    required this.catImage,
    required this.subCategories,
  });

  factory DetailedCategory.fromJson(Map<String, dynamic> json) {
    return DetailedCategory(
      catID: json['catID'] ?? 0,
      catName: json['catName'] ?? '',
      catImage: json['catImage'] ?? '',
      subCategories: json['subCategories'] != null
          ? (json['subCategories'] as List)
              .map((i) => DetailedCategory.fromJson(i))
              .toList()
          : [],
    );
  }
}
