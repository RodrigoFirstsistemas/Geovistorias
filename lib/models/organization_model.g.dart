// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationModel _$OrganizationModelFromJson(Map<String, dynamic> json) =>
    OrganizationModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      cnpj: json['cnpj'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      logoUrl: json['logoUrl'] as String?,
      planType: json['planType'] as String,
      inspectionLimit: (json['inspectionLimit'] as num).toInt(),
      userLimit: (json['userLimit'] as num).toInt(),
      isActive: json['isActive'] as bool? ?? true,
      trialEndsAt: json['trialEndsAt'] == null
          ? null
          : DateTime.parse(json['trialEndsAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      settings: json['settings'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$OrganizationModelToJson(OrganizationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cnpj': instance.cnpj,
      'email': instance.email,
      'phone': instance.phone,
      'logoUrl': instance.logoUrl,
      'planType': instance.planType,
      'inspectionLimit': instance.inspectionLimit,
      'userLimit': instance.userLimit,
      'isActive': instance.isActive,
      'trialEndsAt': instance.trialEndsAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'settings': instance.settings,
    };
