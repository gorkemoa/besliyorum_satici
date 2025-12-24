class DocumentModel {
  final int contractID;
  final String contractName;
  final String contractDesc;
  final String publishDate;

  DocumentModel({
    required this.contractID,
    required this.contractName,
    required this.contractDesc,
    required this.publishDate,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      contractID: json['contractID'] ?? 0,
      contractName: json['contractName'] ?? '',
      contractDesc: json['contractDesc'] ?? '',
      publishDate: json['publishDate'] ?? '',
    );
  }
}

class DocumentsDataModel {
  final String documentInfo;
  final List<DocumentModel> documents;

  DocumentsDataModel({
    required this.documentInfo,
    required this.documents,
  });

  factory DocumentsDataModel.fromJson(Map<String, dynamic> json) {
    return DocumentsDataModel(
      documentInfo: json['documentInfo'] ?? '',
      documents: (json['documents'] as List<dynamic>?)
              ?.map((doc) => DocumentModel.fromJson(doc as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DocumentsResponseModel {
  final bool error;
  final bool success;
  final DocumentsDataModel? data;
  final String code200;

  DocumentsResponseModel({
    required this.error,
    required this.success,
    this.data,
    required this.code200,
  });

  factory DocumentsResponseModel.fromJson(Map<String, dynamic> json) {
    return DocumentsResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null
          ? DocumentsDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      code200: json['200'] ?? '',
    );
  }
}
