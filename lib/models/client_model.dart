import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'client_model.g.dart';

@JsonSerializable()
@Collection()
class ClientModel {
  Id id = Isar.autoIncrement;
  String? remoteId;
  String name;
  String? document;
  String? phone;
  String? email;
  String? address;
  String organizationId;
  @JsonKey(fromJson: _detailsFromJson, toJson: _detailsToJson)
  @Ignore()
  Map<String, dynamic>? details;
  @JsonKey(ignore: true)
  String? detailsJson;
  @JsonKey(required: true)
  DateTime createdAt;
  @JsonKey(required: true)
  DateTime updatedAt;
  bool needsSync;

  ClientModel({
    this.remoteId,
    required this.name,
    this.document,
    this.phone,
    this.email,
    this.address,
    required this.organizationId,
    this.details,
    required this.createdAt,
    required this.updatedAt,
    this.needsSync = false,
  }) {
    _updateDetailsJson();
  }

  void _updateDetailsJson() {
    if (details != null) {
      detailsJson = jsonEncode(details);
    } else {
      detailsJson = null;
    }
  }

  static Map<String, dynamic>? _detailsFromJson(Map<String, dynamic>? json) => json;
  static Map<String, dynamic>? _detailsToJson(Map<String, dynamic>? details) => details;

  factory ClientModel.fromJson(Map<String, dynamic> json) =>
      _$ClientModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClientModelToJson(this);

  factory ClientModel.create({
    String? remoteId,
    required String name,
    String? document,
    String? phone,
    String? email,
    String? address,
    required String organizationId,
    Map<String, dynamic>? details,
  }) {
    final now = DateTime.now();
    return ClientModel(
      remoteId: remoteId,
      name: name,
      document: document,
      phone: phone,
      email: email,
      address: address,
      organizationId: organizationId,
      details: details,
      createdAt: now,
      updatedAt: now,
      needsSync: true,
    );
  }
}
