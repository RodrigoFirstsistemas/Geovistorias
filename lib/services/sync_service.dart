import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import './database_service.dart';
import './api_service.dart';
import '../models/sync_queue_model.dart';
import '../services/notification_service.dart';

class SyncService extends GetxService {
  final _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;
  Timer? _syncTimer;
  final _isSyncing = false.obs;
  final _lastSyncTime = Rx<DateTime?>(null);
  final _syncStatus = 'idle'.obs;
  final _hasConnection = false.obs;
  final _pendingSyncCount = 0.obs;
  final _pendingPropertyCount = 0.obs;
  final _pendingInspectionCount = 0.obs;
  final _pendingClientCount = 0.obs;
  final _pendingPhotoCount = 0.obs;

  final _notificationService = Get.find<NotificationService>();
  final _databaseService = Get.find<DatabaseService>();

  @override
  void onInit() {
    super.onInit();
    _setupConnectivityListener();
    _setupPeriodicSync();
    _updateConnectionStatus();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    super.onClose();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
      if (result != ConnectivityResult.none) {
        syncData();
      }
    });
  }

  void _setupPeriodicSync() {
    // Tentar sincronizar a cada 15 minutos quando houver conexão
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (timer) async {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        syncData();
      }
    });
  }

  void _updateConnectionStatus([ConnectivityResult? result]) {
    if (result == null) {
      _connectivity.checkConnectivity().then((value) {
        _hasConnection.value = value != ConnectivityResult.none;
      });
    } else {
      _hasConnection.value = result != ConnectivityResult.none;
    }
    if (_hasConnection.value) {
      _checkPendingSync();
    }
  }

  Future<void> _checkPendingSync() async {
    final pendingProperties = await DatabaseService.getPendingProperties();
    final pendingInspections = await DatabaseService.getPendingInspections();
    final pendingClients = await DatabaseService.getPendingClients();
    final pendingPhotos = await DatabaseService.getPendingPhotos();

    _pendingPropertyCount.value = pendingProperties.length;
    _pendingInspectionCount.value = pendingInspections.length;
    _pendingClientCount.value = pendingClients.length;
    _pendingPhotoCount.value = pendingPhotos.length;

    _pendingSyncCount.value = _pendingPropertyCount.value +
        _pendingInspectionCount.value +
        _pendingClientCount.value +
        _pendingPhotoCount.value;

    if (_pendingSyncCount.value > 0 && !_isSyncing.value) {
      _notificationService.showNotification(
        title: 'Sincronização Pendente',
        body: 'Existem ${_pendingSyncCount.value} alterações para sincronizar',
      );
    }
  }

  Future<bool> hasInternetConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> syncData() async {
    if (!_hasConnection.value || _isSyncing.value) return;

    try {
      _isSyncing.value = true;
      _syncStatus.value = 'syncing';

      final pendingItems = await DatabaseService.getPendingSyncItems();
      if (pendingItems.isEmpty) {
        _syncStatus.value = 'up_to_date';
        return;
      }

      for (final item in pendingItems) {
        try {
          await _syncItem(item);
          await DatabaseService.markSyncItemAsCompleted(item.id!);
        } catch (e) {
          await DatabaseService.markSyncItemAsFailed(item.id!, e.toString());
        }
      }

      _lastSyncTime.value = DateTime.now();
      _syncStatus.value = 'completed';

      Get.snackbar(
        'Sincronização',
        'Dados sincronizados com sucesso!',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      _syncStatus.value = 'error';
      Get.snackbar(
        'Erro',
        'Erro ao sincronizar dados: $e',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _isSyncing.value = false;
      await _checkPendingSync();
      if (_pendingSyncCount.value == 0) {
        _notificationService.showSyncCompleteNotification();
      }
    }
  }

  Future<void> _syncItem(SyncQueueModel item) async {
    switch (item.type) {
      case 'property':
        await _syncProperty(item);
        break;
      case 'inspection':
        await _syncInspection(item);
        break;
      case 'client':
        await _syncClient(item);
        break;
    }
  }

  Future<void> _syncProperty(SyncQueueModel item) async {
    if (item.operation == 'delete') {
      await ApiService.deleteProperty(item.itemId);
    } else {
      final property = await DatabaseService.getProperty(item.itemId);
      if (property != null) {
        await ApiService.upsertProperty(property);
      }
    }
  }

  Future<void> _syncInspection(SyncQueueModel item) async {
    if (item.operation == 'delete') {
      await ApiService.deleteInspection(item.itemId);
    } else {
      final inspection = await DatabaseService.getInspection(item.itemId);
      if (inspection != null) {
        await ApiService.upsertInspection(inspection);
      }
    }
  }

  Future<void> _syncClient(SyncQueueModel item) async {
    if (item.operation == 'delete') {
      await ApiService.deleteClient(item.itemId);
    } else {
      final client = await DatabaseService.getClient(item.itemId);
      if (client != null) {
        await ApiService.upsertClient(client);
      }
    }
  }

  // Backup Functions
  Future<void> createBackup() async {
    try {
      _syncStatus.value = 'backing_up';
      final data = await DatabaseService.exportData();
      await ApiService.createBackup(data);
      
      Get.snackbar(
        'Backup',
        'Backup criado com sucesso!',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao criar backup: $e',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _syncStatus.value = 'idle';
    }
  }

  Future<void> restoreBackup() async {
    try {
      _syncStatus.value = 'restoring';
      final data = await ApiService.getLatestBackup();
      await DatabaseService.importData(data);
      
      Get.snackbar(
        'Restauração',
        'Backup restaurado com sucesso!',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao restaurar backup: $e',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _syncStatus.value = 'idle';
    }
  }

  // Getters for observables
  bool get isSyncing => _isSyncing.value;
  DateTime? get lastSyncTime => _lastSyncTime.value;
  String get syncStatus => _syncStatus.value;
  bool get hasConnection => _hasConnection.value;
  int get pendingSyncCount => _pendingSyncCount.value;
  int get pendingPropertyCount => _pendingPropertyCount.value;
  int get pendingInspectionCount => _pendingInspectionCount.value;
  int get pendingClientCount => _pendingClientCount.value;
  int get pendingPhotoCount => _pendingPhotoCount.value;

  // Métodos para adicionar itens à fila de sincronização
  Future<void> addPropertyToSync(String propertyId) async {
    await _databaseService.markPropertyForSync(propertyId);
    await _checkPendingSync();
  }

  Future<void> addInspectionToSync(String inspectionId) async {
    await _databaseService.markInspectionForSync(inspectionId);
    await _checkPendingSync();
  }

  Future<void> addClientToSync(String clientId) async {
    await _databaseService.markClientForSync(clientId);
    await _checkPendingSync();
  }

  Future<void> addPhotoToSync(String photoId) async {
    await _databaseService.markPhotoForSync(photoId);
    await _checkPendingSync();
  }
}
