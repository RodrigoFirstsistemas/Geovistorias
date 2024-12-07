import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/organization_model.dart';
import '../../../services/auth_service.dart';

class InspectionRepository {
  final _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService.to;

  Future<List<Map<String, dynamic>>> getAll({
    int? limit,
    int? offset,
    String? status,
  }) async {
    try {
      // Obtém a organização do usuário atual
      final userId = _authService.currentUser.value?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      // Verifica limites da organização
      final orgId = _authService.currentUser.value?.organizationId;
      if (orgId != null) {
        final orgResponse = await _supabase
            .from('organizations')
            .select()
            .match({'id': orgId})
            .single();
        
        final organization = OrganizationModel.fromJson(orgResponse);

        // Verifica se a organização está ativa
        if (!organization.isActive) {
          throw Exception('Organização inativa');
        }

        // Verifica se está no período de trial ou se é uma organização paga
        if (!organization.isTrialActive && organization.planType == 'free') {
          throw Exception('Período de trial expirado');
        }

        // Verifica limite de vistorias
        final inspectionCount = await _getInspectionCount(orgId);

        if (inspectionCount >= organization.inspectionLimit) {
          throw Exception('Limite de vistorias atingido');
        }
      }

      // Monta a query base
      var query = _supabase
          .from('inspections')
          .select()
          .match({'organization_id': orgId})
          .order('created_at', ascending: false);

      // Aplica filtros
      if (status != null) {
        query = query.eq('status', status);
      }

      // Aplica paginação
      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar vistorias: ${e.toString()}');
    }
  }

  Future<void> validateInspectionLimit(String organizationId) async {
    final organization = await _getOrganization(organizationId);
    final inspectionCount = await _getInspectionCount(organizationId);

    if (!organization.isTrialActive && organization.planType == 'free') {
      throw Exception('Trial period has expired. Please upgrade your plan.');
    }

    if (inspectionCount >= organization.inspectionLimit) {
      throw Exception('Inspection limit reached. Please upgrade your plan.');
    }
  }

  Future<OrganizationModel> _getOrganization(String organizationId) async {
    final response = await _supabase
        .from('organizations')
        .select()
        .match({'id': organizationId})
        .single();
    
    return OrganizationModel.fromJson(response);
  }

  Future<int> _getInspectionCount(String organizationId) async {
    final response = await _supabase
        .from('inspections')
        .select('id', const FetchOptions(count: CountOption.exact))
        .match({'organization_id': organizationId});

    return response.count ?? 0;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    try {
      final userId = _authService.currentUser.value?.id;
      final orgId = _authService.currentUser.value?.organizationId;
      
      if (userId == null || orgId == null) {
        throw Exception('Usuário não autenticado');
      }

      // Verifica limites antes de criar
      await validateInspectionLimit(orgId);

      // Adiciona dados da organização e usuário
      data['organization_id'] = orgId;
      data['created_by'] = userId;
      data['created_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('inspections')
          .insert(data)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao criar vistoria: ${e.toString()}');
    }
  }
}
