import 'package:json_annotation/json_annotation.dart';

part 'inspection_model.g.dart';

enum InspectionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

enum InspectionType {
  @JsonValue('residential')
  residential,
  @JsonValue('commercial')
  commercial,
  @JsonValue('industrial')
  industrial,
  @JsonValue('land')
  land,
  @JsonValue('other')
  other,
}

@JsonSerializable()
class InspectionModel {
  final String? id;
  final String organizationId;
  final String propertyId;
  final String inspectorId;
  final String? clientId;
  final InspectionType type;
  final InspectionStatus status;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String? notes;
  final Map<String, dynamic> data;
  final List<String> photos;
  final List<String> documents;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String address;
  final List<String> images;
  final Map<String, dynamic> details;
  final DateTime date;
  final String? description;

  InspectionModel({
    this.id,
    required this.organizationId,
    required this.propertyId,
    required this.inspectorId,
    this.clientId,
    required this.type,
    required this.status,
    required this.scheduledDate,
    this.completedDate,
    this.notes,
    Map<String, dynamic>? data,
    List<String>? photos,
    List<String>? documents,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.address,
    List<String>? images,
    Map<String, dynamic>? details,
    DateTime? date,
    this.description,
  })  : data = data ?? {},
        photos = photos ?? [],
        documents = documents ?? [],
        metadata = metadata ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        images = images ?? [],
        details = details ?? {},
        date = date ?? DateTime.now();

  factory InspectionModel.fromJson(Map<String, dynamic> json) =>
      _$InspectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$InspectionModelToJson(this);

  InspectionModel copyWith({
    String? id,
    String? organizationId,
    String? propertyId,
    String? inspectorId,
    String? clientId,
    InspectionType? type,
    InspectionStatus? status,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? notes,
    Map<String, dynamic>? data,
    List<String>? photos,
    List<String>? documents,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? address,
    List<String>? images,
    Map<String, dynamic>? details,
    DateTime? date,
    String? description,
  }) {
    return InspectionModel(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      propertyId: propertyId ?? this.propertyId,
      inspectorId: inspectorId ?? this.inspectorId,
      clientId: clientId ?? this.clientId,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      data: data ?? Map.from(this.data),
      photos: photos ?? List.from(this.photos),
      documents: documents ?? List.from(this.documents),
      metadata: metadata ?? Map.from(this.metadata),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      address: address ?? this.address,
      images: images ?? List.from(this.images),
      details: details ?? Map.from(this.details),
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}
