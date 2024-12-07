import 'package:sistema_vistorias/models/client_model.dart';
import 'package:sistema_vistorias/models/inspection_model.dart';
import 'package:sistema_vistorias/models/property_model.dart';
import 'package:sistema_vistorias/services/supabase_service.dart';

class ApiService {
  static Future<void> upsertProperty(PropertyModel property) async {
    final supabase = SupabaseService.client;
    await supabase.from('properties').upsert(property.toJson());
  }

  static Future<void> deleteProperty(String id) async {
    final supabase = SupabaseService.client;
    await supabase.from('properties').delete().eq('id', id);
  }

  static Future<void> upsertInspection(InspectionModel inspection) async {
    final supabase = SupabaseService.client;
    await supabase.from('inspections').upsert(inspection.toJson());
  }

  static Future<void> deleteInspection(String id) async {
    final supabase = SupabaseService.client;
    await supabase.from('inspections').delete().eq('id', id);
  }

  static Future<void> upsertClient(ClientModel client) async {
    final supabase = SupabaseService.client;
    await supabase.from('clients').upsert(client.toJson());
  }

  static Future<void> deleteClient(String id) async {
    final supabase = SupabaseService.client;
    await supabase.from('clients').delete().eq('id', id);
  }

  static Future<void> createBackup(Map<String, dynamic> data) async {
    final supabase = SupabaseService.client;
    await supabase.from('backups').insert(data);
  }

  static Future<Map<String, dynamic>?> getLatestBackup() async {
    final supabase = SupabaseService.client;
    final response = await supabase
        .from('backups')
        .select()
        .order('created_at', ascending: false)
        .limit(1)
        .single();
    return response as Map<String, dynamic>?;
  }
}
