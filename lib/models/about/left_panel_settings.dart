import 'settings_field.dart';

class LeftPanelSettings {
  final String code;
  final String title;
  final List<SettingsField> fields;

  LeftPanelSettings({
    required this.code,
    required this.title,
    required this.fields,
  });

  factory LeftPanelSettings.fromJson(Map<String, dynamic> json) {
    return LeftPanelSettings(
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      fields: (json['fields'] as List<dynamic>?)
              ?.map((field) => SettingsField.fromJson(field))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      'fields': fields.map((field) => field.toJson()).toList(),
    };
  }
}
