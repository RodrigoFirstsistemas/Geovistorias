import 'package:json_annotation/json_annotation.dart';

part 'cash_register_model.g.dart';

enum CashRegisterStatus {
  open,
  closed,
  blocked
}

enum TransactionType {
  opening,
  closing,
  withdrawal,
  deposit,
  sangria
}

@JsonSerializable()
class CashRegisterModel {
  final String id;
  final String organizationId;
  final String userId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final double initialAmount;
  final double currentAmount;
  final double? closingAmount;
  final CashRegisterStatus status;
  final String? notes;
  final List<CashTransaction> transactions;

  CashRegisterModel({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.openedAt,
    this.closedAt,
    required this.initialAmount,
    required this.currentAmount,
    this.closingAmount,
    required this.status,
    this.notes,
    required this.transactions,
  });

  factory CashRegisterModel.fromJson(Map<String, dynamic> json) =>
      _$CashRegisterModelFromJson(json);

  Map<String, dynamic> toJson() => _$CashRegisterModelToJson(this);

  bool get isOpen => status == CashRegisterStatus.open;
  bool get isClosed => status == CashRegisterStatus.closed;
  bool get isBlocked => status == CashRegisterStatus.blocked;

  double get totalWithdrawals => transactions
      .where((t) => t.type == TransactionType.withdrawal)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalDeposits => transactions
      .where((t) => t.type == TransactionType.deposit)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalSangria => transactions
      .where((t) => t.type == TransactionType.sangria)
      .fold(0, (sum, t) => sum + t.amount);

  double calculateExpectedAmount() {
    return initialAmount + totalDeposits - totalWithdrawals - totalSangria;
  }

  double calculateDifference() {
    return currentAmount - calculateExpectedAmount();
  }
}

@JsonSerializable()
class CashTransaction {
  final String id;
  final String cashRegisterId;
  final String userId;
  final TransactionType type;
  final double amount;
  final DateTime timestamp;
  final String? description;
  final String? approvedBy;

  CashTransaction({
    required this.id,
    required this.cashRegisterId,
    required this.userId,
    required this.type,
    required this.amount,
    required this.timestamp,
    this.description,
    this.approvedBy,
  });

  factory CashTransaction.fromJson(Map<String, dynamic> json) =>
      _$CashTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$CashTransactionToJson(this);
}
