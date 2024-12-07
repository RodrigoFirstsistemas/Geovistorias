// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyModel _$PropertyModelFromJson(Map<String, dynamic> json) =>
    PropertyModel(
      id: json['id'] as String?,
      cep: json['cep'] as String,
      street: json['street'] as String,
      number: json['number'] as String,
      complement: json['complement'] as String?,
      neighborhood: json['neighborhood'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      type: $enumDecode(_$PropertyTypeEnumMap, json['type'],
          unknownValue: PropertyType.other),
      subtype: json['subtype'] as String?,
      organizationId: json['organizationId'] as String,
      details: json['details'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PropertyModelToJson(PropertyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cep': instance.cep,
      'street': instance.street,
      'number': instance.number,
      'complement': instance.complement,
      'neighborhood': instance.neighborhood,
      'city': instance.city,
      'state': instance.state,
      'type': _$PropertyTypeEnumMap[instance.type]!,
      'subtype': instance.subtype,
      'organizationId': instance.organizationId,
      'details': instance.details,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$PropertyTypeEnumMap = {
  PropertyType.residential: 'residential',
  PropertyType.commercial: 'commercial',
  PropertyType.industrial: 'industrial',
  PropertyType.land: 'land',
  PropertyType.rural: 'rural',
  PropertyType.apartment: 'apartment',
  PropertyType.other: 'other',
};
