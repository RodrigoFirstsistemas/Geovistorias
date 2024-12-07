import 'dart:convert';

enum DocumentType {
  pdf,
  word,
  receipt,
}

class DocumentTemplate {
  final String? id;
  final String name;
  final String template;
  final DocumentType type;
  final Map<String, dynamic> headerConfig;
  final Map<String, dynamic> footerConfig;
  final Map<String, dynamic> bodyConfig;
  final String organizationId;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DocumentTemplate({
    this.id,
    required this.name,
    required this.template,
    required this.type,
    Map<String, dynamic>? headerConfig,
    Map<String, dynamic>? footerConfig,
    Map<String, dynamic>? bodyConfig,
    required this.organizationId,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  })  : headerConfig = headerConfig ?? {},
        footerConfig = footerConfig ?? {},
        bodyConfig = bodyConfig ?? {};

  factory DocumentTemplate.fromJson(Map<String, dynamic> json) {
    return DocumentTemplate(
      id: json['id'],
      name: json['name'],
      template: json['template'],
      type: DocumentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => DocumentType.pdf,
      ),
      headerConfig: json['header_config'] != null
          ? jsonDecode(json['header_config'])
          : {},
      footerConfig: json['footer_config'] != null
          ? jsonDecode(json['footer_config'])
          : {},
      bodyConfig:
          json['body_config'] != null ? jsonDecode(json['body_config']) : {},
      organizationId: json['organization_id'],
      isDefault: json['is_default'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'template': template,
      'type': type.toString().split('.').last,
      'header_config': jsonEncode(headerConfig),
      'footer_config': jsonEncode(footerConfig),
      'body_config': jsonEncode(bodyConfig),
      'organization_id': organizationId,
      'is_default': isDefault,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DocumentTemplate copyWith({
    String? id,
    String? name,
    String? template,
    DocumentType? type,
    Map<String, dynamic>? headerConfig,
    Map<String, dynamic>? footerConfig,
    Map<String, dynamic>? bodyConfig,
    String? organizationId,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      template: template ?? this.template,
      type: type ?? this.type,
      headerConfig: headerConfig ?? Map.from(this.headerConfig),
      footerConfig: footerConfig ?? Map.from(this.footerConfig),
      bodyConfig: bodyConfig ?? Map.from(this.bodyConfig),
      organizationId: organizationId ?? this.organizationId,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DocumentConfig {
  final String companyName;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String cnpj;
  final String logoPath;
  final String? watermarkText;
  final String? watermarkImage;
  final Map<String, double> margins;
  final Map<String, String> colors;

  DocumentConfig({
    required this.companyName,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.cnpj,
    required this.logoPath,
    this.watermarkText,
    this.watermarkImage,
    Map<String, double>? margins,
    Map<String, String>? colors,
  })  : margins = margins ??
            {
              'top': 20,
              'right': 20,
              'bottom': 20,
              'left': 20,
              'all': 20,
            },
        colors = colors ??
            {
              'primary': '#1976D2',
              'secondary': '#424242',
              'accent': '#82B1FF',
              'error': '#FF5252',
            };

  factory DocumentConfig.fromJson(Map<String, dynamic> json) {
    return DocumentConfig(
      companyName: json['company_name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      cnpj: json['cnpj'],
      logoPath: json['logo_path'],
      watermarkText: json['watermark_text'],
      watermarkImage: json['watermark_image'],
      margins: Map<String, double>.from(json['margins'] ?? {}),
      colors: Map<String, String>.from(json['colors'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'cnpj': cnpj,
      'logo_path': logoPath,
      'watermark_text': watermarkText,
      'watermark_image': watermarkImage,
      'margins': margins,
      'colors': colors,
    };
  }

  DocumentConfig copyWith({
    String? companyName,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? cnpj,
    String? logoPath,
    String? watermarkText,
    String? watermarkImage,
    Map<String, double>? margins,
    Map<String, String>? colors,
  }) {
    return DocumentConfig(
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      cnpj: cnpj ?? this.cnpj,
      logoPath: logoPath ?? this.logoPath,
      watermarkText: watermarkText ?? this.watermarkText,
      watermarkImage: watermarkImage ?? this.watermarkImage,
      margins: margins ?? Map.from(this.margins),
      colors: colors ?? Map.from(this.colors),
    );
  }
}
