import 'package:json_annotation/json_annotation.dart';
import 'package:isar/isar.dart';

part 'user_model.g.dart';

enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('operator')
  operator,
  @JsonValue('inspector')
  inspector,
  @JsonValue('viewer')
  viewer,
  @JsonValue('cashier')
  cashier
}

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final UserRole role;
  final String? organizationId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool needsSync;
  final DateTime? lastSyncAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phone,
    required this.role,
    this.organizationId,
    this.isActive = true,
    DateTime? createdAt,
    this.lastLoginAt,
    this.needsSync = true,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  bool get isAdmin => role == UserRole.admin;
  bool get isManager => role == UserRole.manager;
  bool get isOperator => role == UserRole.operator;
}
