import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/organization_model.dart';
import '../models/user_model.dart';

class AdminService extends GetxService {
  static AdminService get to => Get.find();
  final _supabase = Supabase.instance.client;

  // Organizações
  Future<List<OrganizationModel>> getOrganizations({
    int? limit,
    int? offset,
    String? searchTerm,
  }) async {
    try {
      var query = _supabase
          .from('organizations')
          .select()
          .order('created_at', ascending: false);

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.ilike('name', '%${searchTerm}%');
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      return response
          .map((json) => OrganizationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar organizações: ${e.toString()}');
    }
  }

  Future<List<OrganizationModel>> searchOrganizations(String query) async {
    final response = await _supabase
        .from('organizations')
        .select()
        .match({'name': query});

    return (response as List)
        .map((json) => OrganizationModel.fromJson(json))
        .toList();
  }

  // Usuários por organização
  Future<List<UserModel>> getUsersByOrganization(
    String organizationId, {
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _supabase
          .from('users')
          .select()
          .eq('organization_id', organizationId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar usuários: ${e.toString()}');
    }
  }

  // Criar organização
  Future<OrganizationModel> createOrganization(
    String name,
    String planType, {
    String? logoUrl,
    int? inspectionLimit,
    int? userLimit,
    DateTime? trialEndsAt,
  }) async {
    try {
      final organization = {
        'name': name,
        'plan_type': planType,
        'logo_url': logoUrl,
        'inspection_limit': inspectionLimit ?? 100,
        'user_limit': userLimit ?? 5,
        'trial_ends_at': trialEndsAt?.toIso8601String(),
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('organizations')
          .insert(organization)
          .select()
          .single();

      return OrganizationModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar organização: ${e.toString()}');
    }
  }

  // Atualizar organização
  Future<OrganizationModel> updateOrganization(
    String id, {
    String? name,
    String? logoUrl,
    String? planType,
    int? inspectionLimit,
    int? userLimit,
    DateTime? trialEndsAt,
    bool? isActive,
  }) async {
    try {
      final updates = {
        if (name != null) 'name': name,
        if (logoUrl != null) 'logo_url': logoUrl,
        if (planType != null) 'plan_type': planType,
        if (inspectionLimit != null) 'inspection_limit': inspectionLimit,
        if (userLimit != null) 'user_limit': userLimit,
        if (trialEndsAt != null) 'trial_ends_at': trialEndsAt.toIso8601String(),
        if (isActive != null) 'is_active': isActive,
      };

      final response = await _supabase
          .from('organizations')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return OrganizationModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar organização: ${e.toString()}');
    }
  }

  Future<void> updateOrganizationStatus(String id, bool isActive) async {
    await _supabase
        .from('organizations')
        .update({'is_active': isActive})
        .match({'id': id});
  }

  Future<void> deleteOrganization(String id) async {
    await _supabase
        .from('organizations')
        .delete()
        .match({'id': id});
  }

  // Estatísticas gerais
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final organizations = await _supabase
          .from('organizations')
          .select('id, is_active')
          .execute();

      final users = await _supabase
          .from('users')
          .select('id, is_active')
          .execute();

      final inspections = await _supabase
          .from('inspections')
          .select('id, status')
          .execute();

      return {
        'total_organizations': organizations.count,
        'active_organizations': organizations.data
            .where((org) => org['is_active'] == true)
            .length,
        'total_users': users.count,
        'active_users':
            users.data.where((user) => user['is_active'] == true).length,
        'total_inspections': inspections.count,
        'completed_inspections': inspections.data
            .where((inspection) => inspection['status'] == 'completed')
            .length,
      };
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas: ${e.toString()}');
    }
  }
}
