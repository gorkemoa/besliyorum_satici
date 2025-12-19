class ContractModel {
  final String title;
  final String content;

  ContractModel({required this.title, required this.content});

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      title: json['policyTitle'] ?? '',
      content: json['policyContent'] ?? '',
    );
  }

  /// HTML etiketlerini temizleyerek düz metin döndürür
  String get plainContent {
    return _removeHtmlTags(content);
  }

  /// HTML etiketlerini temizleyen yardımcı metod
  static String _removeHtmlTags(String htmlText) {
    // HTML entities decode
    String text = htmlText
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&uuml;', 'ü')
        .replaceAll('&ccedil;', 'ç')
        .replaceAll('&Ouml;', 'Ö')
        .replaceAll('&Uuml;', 'Ü')
        .replaceAll('&Ccedil;', 'Ç')
        .replaceAll('&iacute;', 'ı')
        .replaceAll('&Iacute;', 'İ')
        .replaceAll('&acirc;', 'â')
        .replaceAll('&Acirc;', 'Â')
        .replaceAll('&rsquo;', "'")
        .replaceAll('&lsquo;', "'")
        .replaceAll('&rdquo;', '"')
        .replaceAll('&ldquo;', '"')
        .replaceAll('&ndash;', '-')
        .replaceAll('&mdash;', '—')
        .replaceAll('&bull;', '•')
        .replaceAll('&hellip;', '...');

    // HTML taglarını kaldır
    final RegExp htmlTagRegExp = RegExp(r'<[^>]*>', multiLine: true);
    text = text.replaceAll(htmlTagRegExp, '');

    // Birden fazla boşluğu tek boşluğa dönüştür
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    // Satır başı ve sonundaki boşlukları temizle
    text = text.trim();

    return text;
  }
}

class ContractResponseModel {
  final bool error;
  final bool success;
  final ContractModel? data;
  final String? errorMessage;

  ContractResponseModel({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory ContractResponseModel.fromJson(Map<String, dynamic> json) {
    return ContractResponseModel(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null
          ? ContractModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errorMessage: json['error_message'],
    );
  }
}
