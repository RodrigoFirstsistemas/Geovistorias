import 'package:isar/isar.dart';

@collection
class Terminal {
  Id id = Isar.autoIncrement;
  
  @Index(type: IndexType.value)
  String? remoteId;
  
  String deviceId; // ID único do dispositivo
  String serialNumber; // Número de série do terminal
  String terminalNumber; // Número do terminal Stone
  String stoneCode; // Código Stone
  
  // Informações do usuário
  String userName;
  String userEmail;
  String userPhone;
  
  // Informações de acesso
  @Enumerated(EnumType.name)
  TerminalStatus status;
  DateTime registeredAt;
  DateTime? approvedAt;
  String? approvedBy;
  DateTime? lastAccessAt;
  String? rejectionReason;
  
  // Credenciais Stone
  String? packagecloudToken;
  bool isConfigured;
  
  // Controle de sincronização
  bool needsSync;
  DateTime? lastSyncAt;

  Terminal({
    required this.deviceId,
    required this.serialNumber,
    required this.terminalNumber,
    required this.stoneCode,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    this.status = TerminalStatus.pending,
    this.isConfigured = false,
    this.needsSync = true,
  }) : registeredAt = DateTime.now();

  void approve(String adminId) {
    status = TerminalStatus.approved;
    approvedAt = DateTime.now();
    approvedBy = adminId;
    needsSync = true;
  }

  void reject(String reason) {
    status = TerminalStatus.rejected;
    rejectionReason = reason;
    needsSync = true;
  }

  void configureStone(String packagecloudToken) {
    this.packagecloudToken = packagecloudToken;
    isConfigured = true;
    needsSync = true;
  }

  void recordAccess() {
    lastAccessAt = DateTime.now();
    needsSync = true;
  }
}

enum TerminalStatus {
  pending,
  approved,
  rejected,
  blocked,
}
