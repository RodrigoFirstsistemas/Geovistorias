import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inspection_model.dart';

class InspectionService {
  final SupabaseClient _supabase;
  static const String _table = 'inspections';

  InspectionService(this._supabase);

  Future<List<InspectionModel>> getInspections({
    String? organizationId,
    String? inspectorId,
    String? clientId,
    InspectionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _supabase.from(_table).select();

    if (organizationId != null) {
      query = query.eq('organization_id', organizationId);
    }
    if (inspectorId != null) {
      query = query.eq('inspector_id', inspectorId);
    }
    if (clientId != null) {
      query = query.eq('client_id', clientId);
    }
    if (status != null) {
      query = query.eq('status', status.toString().split('.').last);
    }
    if (startDate != null) {
      query = query.gte('scheduled_date', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('scheduled_date', endDate.toIso8601String());
    }

    final response = await query;
    return (response as List)
        .map((json) => InspectionModel.fromJson(json))
        .toList();
  }

  Future<InspectionModel> getInspection(String id) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('id', id)
        .single();
    return InspectionModel.fromJson(response);
  }

  Future<InspectionModel> createInspection(InspectionModel inspection) async {
    final response = await _supabase
        .from(_table)
        .insert(inspection.toJson())
        .select()
        .single();
    return InspectionModel.fromJson(response);
  }

  Future<InspectionModel> updateInspection(InspectionModel inspection) async {
    if (inspection.id == null) {
      throw Exception('Inspection ID cannot be null for update operation');
    }

    final response = await _supabase
        .from(_table)
        .update(inspection.toJson())
        .eq('id', inspection.id)
        .select()
        .single();
    return InspectionModel.fromJson(response);
  }

  Future<void> deleteInspection(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }

  Future<void> addPhoto(String inspectionId, String photoUrl) async {
    final inspection = await getInspection(inspectionId);
    final updatedPhotos = List<String>.from(inspection.photos)..add(photoUrl);
    
    await _supabase
        .from(_table)
        .update({'photos': updatedPhotos})
        .eq('id', inspectionId);
  }

  Future<void> removePhoto(String inspectionId, String photoUrl) async {
    final inspection = await getInspection(inspectionId);
    final updatedPhotos = List<String>.from(inspection.photos)
      ..removeWhere((photo) => photo == photoUrl);
    
    await _supabase
        .from(_table)
        .update({'photos': updatedPhotos})
        .eq('id', inspectionId);
  }

  Future<void> addDocument(String inspectionId, String documentUrl) async {
    final inspection = await getInspection(inspectionId);
    final updatedDocuments = List<String>.from(inspection.documents)
      ..add(documentUrl);
    
    await _supabase
        .from(_table)
        .update({'documents': updatedDocuments})
        .eq('id', inspectionId);
  }

  Future<void> removeDocument(String inspectionId, String documentUrl) async {
    final inspection = await getInspection(inspectionId);
    final updatedDocuments = List<String>.from(inspection.documents)
      ..removeWhere((doc) => doc == documentUrl);
    
    await _supabase
        .from(_table)
        .update({'documents': updatedDocuments})
        .eq('id', inspectionId);
  }

  Future<void> updateStatus(String inspectionId, InspectionStatus status) async {
    await _supabase
        .from(_table)
        .update({
          'status': status.toString().split('.').last,
          if (status == InspectionStatus.completed) 
            'completed_date': DateTime.now().toIso8601String()
        })
        .eq('id', inspectionId);
  }

  Future<void> updateData(String inspectionId, Map<String, dynamic> data) async {
    final inspection = await getInspection(inspectionId);
    final updatedData = Map<String, dynamic>.from(inspection.data)..addAll(data);
    
    await _supabase
        .from(_table)
        .update({'data': updatedData})
        .eq('id', inspectionId);
  }

  Future<List<InspectionModel>> getInspectionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? organizationId,
    String? inspectorId,
  }) async {
    var query = _supabase
        .from(_table)
        .select()
        .gte('scheduled_date', startDate.toIso8601String())
        .lte('scheduled_date', endDate.toIso8601String());

    if (organizationId != null) {
      query = query.eq('organization_id', organizationId);
    }
    if (inspectorId != null) {
      query = query.eq('inspector_id', inspectorId);
    }

    final response = await query;
    return (response as List)
        .map((json) => InspectionModel.fromJson(json))
        .toList();
  }

  Future<List<InspectionModel>> getPendingInspections({
    String? organizationId,
    String? inspectorId,
  }) async {
    var query = _supabase
        .from(_table)
        .select()
        .eq('status', InspectionStatus.pending.toString().split('.').last);

    if (organizationId != null) {
      query = query.eq('organization_id', organizationId);
    }
    if (inspectorId != null) {
      query = query.eq('inspector_id', inspectorId);
    }

    final response = await query;
    return (response as List)
        .map((json) => InspectionModel.fromJson(json))
        .toList();
  }

  Future<List<InspectionModel>> getCompletedInspections({
    String? organizationId,
    String? inspectorId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _supabase
        .from(_table)
        .select()
        .eq('status', InspectionStatus.completed.toString().split('.').last);

    if (organizationId != null) {
      query = query.eq('organization_id', organizationId);
    }
    if (inspectorId != null) {
      query = query.eq('inspector_id', inspectorId);
    }
    if (startDate != null) {
      query = query.gte('completed_date', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('completed_date', endDate.toIso8601String());
    }

    final response = await query;
    return (response as List)
        .map((json) => InspectionModel.fromJson(json))
        .toList();
  }
}
