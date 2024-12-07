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

  const UserModel({
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
    this.lastSyncAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  bool get isAdmin => role == UserRole.admin;
  bool get isManager => role == UserRole.manager;
  bool get isOperator => role == UserRole.operator;

  bool hasPermission(UserRole minimumRole) {
    final roleValues = UserRole.values;
    final currentRoleIndex = roleValues.indexOf(role);
    final minimumRoleIndex = roleValues.indexOf(minimumRole);
    return currentRoleIndex <= minimumRoleIndex;
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? phone,
    UserRole? role,
    String? organizationId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? needsSync,
    DateTime? lastSyncAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      needsSync: needsSync ?? this.needsSync,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}
