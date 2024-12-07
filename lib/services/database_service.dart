import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/property_model.dart';
import '../models/inspection_model.dart';
import '../models/client_model.dart';
import '../models/sync_queue_model.dart';

class DatabaseService {
  static late Isar _isar;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        PropertyModelSchema,
        InspectionModelSchema,
        ClientModelSchema,
        SyncQueueModelSchema,
      ],
      directory: dir.path,
    );
    _initialized = true;
  }

  // CRUD Operations for Properties
  static Future<void> saveProperty(PropertyModel property) async {
    await _isar.writeTxn(() async {
      await _isar.propertyModels.put(property);
      await _addToSyncQueue('property', property.id!, 'upsert');
    });
  }

  static Future<PropertyModel?> getProperty(int id) async {
    return await _isar.propertyModels.get(id);
  }

  static Stream<List<PropertyModel>> watchProperties() {
    return _isar.propertyModels.where().watch(fireImmediately: true);
  }

  static Future<void> deleteProperty(int id) async {
    await _isar.writeTxn(() async {
      await _isar.propertyModels.delete(id);
      await _addToSyncQueue('property', id, 'delete');
    });
  }

  // CRUD Operations for Inspections
  static Future<void> saveInspection(InspectionModel inspection) async {
    await _isar.writeTxn(() async {
      await _isar.inspectionModels.put(inspection);
      await _addToSyncQueue('inspection', inspection.id!, 'upsert');
    });
  }

  static Future<InspectionModel?> getInspection(int id) async {
    return await _isar.inspectionModels.get(id);
  }

  static Stream<List<InspectionModel>> watchInspections() {
    return _isar.inspectionModels.where().watch(fireImmediately: true);
  }

  static Future<void> deleteInspection(int id) async {
    await _isar.writeTxn(() async {
      await _isar.inspectionModels.delete(id);
      await _addToSyncQueue('inspection', id, 'delete');
    });
  }

  // CRUD Operations for Clients
  static Future<void> saveClient(ClientModel client) async {
    await _isar.writeTxn(() async {
      await _isar.clientModels.put(client);
      await _addToSyncQueue('client', client.id!, 'upsert');
    });
  }

  static Future<ClientModel?> getClient(int id) async {
    return await _isar.clientModels.get(id);
  }

  static Stream<List<ClientModel>> watchClients() {
    return _isar.clientModels.where().watch(fireImmediately: true);
  }

  static Future<void> deleteClient(int id) async {
    await _isar.writeTxn(() async {
      await _isar.clientModels.delete(id);
      await _addToSyncQueue('client', id, 'delete');
    });
  }

  // Sync Queue Operations
  static Future<void> _addToSyncQueue(String type, int id, String operation) async {
    final syncItem = SyncQueueModel()
      ..type = type
      ..itemId = id
      ..operation = operation
      ..timestamp = DateTime.now()
      ..status = 'pending';

    await _isar.writeTxn(() async {
      await _isar.syncQueueModels.put(syncItem);
    });
  }

  static Future<List<SyncQueueModel>> getPendingSyncItems() async {
    return await _isar.syncQueueModels
        .filter()
        .statusEqualTo('pending')
        .findAll();
  }

  static Future<void> markSyncItemAsCompleted(int id) async {
    await _isar.writeTxn(() async {
      final item = await _isar.syncQueueModels.get(id);
      if (item != null) {
        item.status = 'completed';
        await _isar.syncQueueModels.put(item);
      }
    });
  }

  static Future<void> markSyncItemAsFailed(int id, String error) async {
    await _isar.writeTxn(() async {
      final item = await _isar.syncQueueModels.get(id);
      if (item != null) {
        item.status = 'failed';
        item.error = error;
        await _isar.syncQueueModels.put(item);
      }
    });
  }

  // Backup Operations
  static Future<Map<String, dynamic>> exportData() async {
    final properties = await _isar.propertyModels.where().findAll();
    final inspections = await _isar.inspectionModels.where().findAll();
    final clients = await _isar.clientModels.where().findAll();

    return {
      'properties': properties.map((p) => p.toJson()).toList(),
      'inspections': inspections.map((i) => i.toJson()).toList(),
      'clients': clients.map((c) => c.toJson()).toList(),
    };
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    await _isar.writeTxn(() async {
      // Clear existing data
      await _isar.propertyModels.clear();
      await _isar.inspectionModels.clear();
      await _isar.clientModels.clear();

      // Import properties
      for (final propertyJson in data['properties']) {
        final property = PropertyModel.fromJson(propertyJson);
        await _isar.propertyModels.put(property);
      }

      // Import inspections
      for (final inspectionJson in data['inspections']) {
        final inspection = InspectionModel.fromJson(inspectionJson);
        await _isar.inspectionModels.put(inspection);
      }

      // Import clients
      for (final clientJson in data['clients']) {
        final client = ClientModel.fromJson(clientJson);
        await _isar.clientModels.put(client);
      }
    });
  }
}
