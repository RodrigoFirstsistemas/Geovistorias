import 'package:get/get.dart';
import '../models/terminal_model.dart';
import '../services/isar_service.dart';
import '../services/sync_service.dart';

class TerminalController extends GetxController {
  final _isarService = Get.find<IsarService>();
  final _syncService = Get.find<SyncService>();
  
  final _terminals = <Terminal>[].obs;
  final _filteredTerminals = <Terminal>[].obs;
  final _searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTerminals();
    ever(_searchQuery, (_) => _filterTerminals());
  }

  Future<void> _loadTerminals() async {
    final terminals = await _isarService.getAllTerminals();
    _terminals.value = terminals;
    _filterTerminals();
  }

  List<Terminal> getTerminalsByStatus(TerminalStatus status) {
    return _filteredTerminals
        .where((t) => t.status == status)
        .toList();
  }

  void filterTerminals(String query) {
    _searchQuery.value = query.toLowerCase();
  }

  void _filterTerminals() {
    if (_searchQuery.value.isEmpty) {
      _filteredTerminals.value = _terminals;
      return;
    }

    _filteredTerminals.value = _terminals.where((terminal) {
      final query = _searchQuery.value;
      return terminal.userName.toLowerCase().contains(query) ||
          terminal.userEmail.toLowerCase().contains(query) ||
          terminal.terminalNumber.toLowerCase().contains(query) ||
          terminal.serialNumber.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> approveTerminal(String terminalId) async {
    final terminal = _terminals.firstWhere((t) => t.remoteId == terminalId);
    terminal.approve(Get.find<AuthService>().currentUser.value!.id);
    
    await _isarService.saveTerminal(terminal);
    await _syncService.syncTerminal(terminal);
    
    _loadTerminals();
  }

  Future<void> rejectTerminal(String terminalId, String reason) async {
    final terminal = _terminals.firstWhere((t) => t.remoteId == terminalId);
    terminal.reject(reason);
    
    await _isarService.saveTerminal(terminal);
    await _syncService.syncTerminal(terminal);
    
    _loadTerminals();
  }

  Future<void> blockTerminal(String terminalId, String reason) async {
    final terminal = _terminals.firstWhere((t) => t.remoteId == terminalId);
    terminal.status = TerminalStatus.blocked;
    terminal.rejectionReason = reason;
    terminal.needsSync = true;
    
    await _isarService.saveTerminal(terminal);
    await _syncService.syncTerminal(terminal);
    
    _loadTerminals();
  }

  Future<void> unblockTerminal(String terminalId) async {
    final terminal = _terminals.firstWhere((t) => t.remoteId == terminalId);
    terminal.status = TerminalStatus.approved;
    terminal.rejectionReason = null;
    terminal.needsSync = true;
    
    await _isarService.saveTerminal(terminal);
    await _syncService.syncTerminal(terminal);
    
    _loadTerminals();
  }

  Future<void> configureStone(String terminalId, String packagecloudToken) async {
    final terminal = _terminals.firstWhere((t) => t.remoteId == terminalId);
    terminal.configureStone(packagecloudToken);
    
    await _isarService.saveTerminal(terminal);
    await _syncService.syncTerminal(terminal);
    
    _loadTerminals();
  }

  Future<bool> checkTerminalAccess() async {
    final deviceId = await _getDeviceId();
    final terminal = await _isarService.getTerminalByDeviceId(deviceId);
    
    if (terminal == null) {
      return false;
    }

    if (terminal.status != TerminalStatus.approved) {
      return false;
    }

    terminal.recordAccess();
    await _isarService.saveTerminal(terminal);
    await _syncService.syncTerminal(terminal);

    return true;
  }

  Future<void> registerTerminal({
    required String userName,
    required String userEmail,
    required String userPhone,
    required String terminalNumber,
    required String serialNumber,
    required String stoneCode,
  }) async {
    final deviceId = await _getDeviceId();
    
    final terminal = Terminal(
      deviceId: deviceId,
      serialNumber: serialNumber,
      terminalNumber: terminalNumber,
      stoneCode: stoneCode,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
    );

    await _isarService.saveTerminal(terminal);
    await _syncService.syncTerminal(terminal);
  }

  Future<String> _getDeviceId() async {
    // Implementar lógica para obter ID único do dispositivo
    // Pode usar package device_info_plus ou similar
    return 'device_id';
  }
}
