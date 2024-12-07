import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property_model.dart';

class PropertyService {
  final SupabaseClient _supabase;
  static const String _table = 'properties';

  PropertyService(this._supabase);

  Future<List<PropertyModel>> getProperties({String? organizationId}) async {
    var query = _supabase.from(_table).select();
    
    if (organizationId != null) {
      query = query.eq('organization_id', organizationId);
    }

    final response = await query;
    return (response as List)
        .map((json) => PropertyModel.fromJson(json))
        .toList();
  }

  Future<PropertyModel> getProperty(String id) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('id', id)
        .single();
    return PropertyModel.fromJson(response);
  }

  Future<PropertyModel> createProperty(PropertyModel property) async {
    final response = await _supabase
        .from(_table)
        .insert(property.toJson())
        .select()
        .single();
    return PropertyModel.fromJson(response);
  }

  Future<PropertyModel> updateProperty(PropertyModel property) async {
    if (property.id == null) {
      throw Exception('Property ID cannot be null for update operation');
    }

    final response = await _supabase
        .from(_table)
        .update(property.toJson())
        .eq('id', property.id)
        .select()
        .single();
    return PropertyModel.fromJson(response);
  }

  Future<void> deleteProperty(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }
}
