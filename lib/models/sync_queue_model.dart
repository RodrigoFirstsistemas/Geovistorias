import 'package:isar/isar.dart';

part 'sync_queue_model.g.dart';

@Collection()
class SyncQueueModel {
  Id? id;

  @Index()
  late String type; // 'property', 'inspection', 'client', 'photo'

  late int itemId;

  @Index()
  late String operation; // 'upsert', 'delete'

  @Index()
  late DateTime timestamp;

  @Index()
  late String status; // 'pending', 'completed', 'failed'

  String? error;

  // Campos específicos para fotos
  String? fileName;
  String? localPath;
}
