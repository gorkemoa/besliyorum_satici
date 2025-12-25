class SettingsField {
  final String key;
  final String name;
  final FieldSettings settings;

  SettingsField({
    required this.key,
    required this.name,
    required this.settings,
  });

  factory SettingsField.fromJson(Map<String, dynamic> json) {
    return SettingsField(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      settings: FieldSettings.fromJson(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'settings': settings.toJson(),
    };
  }
}

class FieldSettings {
  final bool isVisible;
  final String text;
  final String? url;

  FieldSettings({
    required this.isVisible,
    required this.text,
    this.url,
  });

  factory FieldSettings.fromJson(Map<String, dynamic> json) {
    return FieldSettings(
      isVisible: json['isVisible'] ?? false,
      text: json['text'] ?? '',
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isVisible': isVisible,
      'text': text,
      if (url != null) 'url': url,
    };
  }
}
