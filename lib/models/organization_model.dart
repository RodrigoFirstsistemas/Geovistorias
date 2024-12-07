import 'package:json_annotation/json_annotation.dart';

part 'organization_model.g.dart';

@JsonSerializable()
class OrganizationModel {
  final String? id;
  final String name;
  final String cnpj;
  final String email;
  final String phone;
  final String? logoUrl;
  final String planType;
  final int inspectionLimit;
  final int userLimit;
  final bool isActive;
  final DateTime? trialEndsAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? settings;

  OrganizationModel({
    this.id,
    required this.name,
    required this.cnpj,
    required this.email,
    required this.phone,
    this.logoUrl,
    required this.planType,
    required this.inspectionLimit,
    required this.userLimit,
    this.isActive = true,
    this.trialEndsAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.settings,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory OrganizationModel.fromJson(Map<String, dynamic> json) =>
      _$OrganizationModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationModelToJson(this);

  OrganizationModel copyWith({
    String? id,
    String? name,
    String? cnpj,
    String? email,
    String? phone,
    String? logoUrl,
    String? planType,
    int? inspectionLimit,
    int? userLimit,
    bool? isActive,
    DateTime? trialEndsAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? settings,
  }) {
    return OrganizationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cnpj: cnpj ?? this.cnpj,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      logoUrl: logoUrl ?? this.logoUrl,
      planType: planType ?? this.planType,
      inspectionLimit: inspectionLimit ?? this.inspectionLimit,
      userLimit: userLimit ?? this.userLimit,
      isActive: isActive ?? this.isActive,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
    );
  }

  bool get isTrialActive =>
      trialEndsAt != null && trialEndsAt!.isAfter(DateTime.now());

  int get remainingDaysInTrial {
    if (trialEndsAt == null) return 0;
    return trialEndsAt!.difference(DateTime.now()).inDays;
  }
}
