// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InspectionModel _$InspectionModelFromJson(Map<String, dynamic> json) =>
    InspectionModel(
      id: json['id'] as String?,
      organizationId: json['organizationId'] as String,
      propertyId: json['propertyId'] as String,
      inspectorId: json['inspectorId'] as String,
      clientId: json['clientId'] as String?,
      type: $enumDecode(_$InspectionTypeEnumMap, json['type']),
      status: $enumDecode(_$InspectionStatusEnumMap, json['status']),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      completedDate: json['completedDate'] == null
          ? null
          : DateTime.parse(json['completedDate'] as String),
      notes: json['notes'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      photos:
          (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList(),
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      address: json['address'] as String,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      details: json['details'] as Map<String, dynamic>?,
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$InspectionModelToJson(InspectionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'propertyId': instance.propertyId,
      'inspectorId': instance.inspectorId,
      'clientId': instance.clientId,
      'type': _$InspectionTypeEnumMap[instance.type]!,
      'status': _$InspectionStatusEnumMap[instance.status]!,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'completedDate': instance.completedDate?.toIso8601String(),
      'notes': instance.notes,
      'data': instance.data,
      'photos': instance.photos,
      'documents': instance.documents,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'address': instance.address,
      'images': instance.images,
      'details': instance.details,
      'date': instance.date.toIso8601String(),
      'description': instance.description,
    };

const _$InspectionTypeEnumMap = {
  InspectionType.residential: 'residential',
  InspectionType.commercial: 'commercial',
  InspectionType.industrial: 'industrial',
  InspectionType.land: 'land',
  InspectionType.other: 'other',
};

const _$InspectionStatusEnumMap = {
  InspectionStatus.pending: 'pending',
  InspectionStatus.inProgress: 'in_progress',
  InspectionStatus.completed: 'completed',
  InspectionStatus.cancelled: 'cancelled',
};
