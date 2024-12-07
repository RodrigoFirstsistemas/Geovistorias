// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_register_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CashRegisterModel _$CashRegisterModelFromJson(Map<String, dynamic> json) =>
    CashRegisterModel(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      userId: json['userId'] as String,
      openedAt: DateTime.parse(json['openedAt'] as String),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
      initialAmount: (json['initialAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      closingAmount: (json['closingAmount'] as num?)?.toDouble(),
      status: $enumDecode(_$CashRegisterStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => CashTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CashRegisterModelToJson(CashRegisterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'userId': instance.userId,
      'openedAt': instance.openedAt.toIso8601String(),
      'closedAt': instance.closedAt?.toIso8601String(),
      'initialAmount': instance.initialAmount,
      'currentAmount': instance.currentAmount,
      'closingAmount': instance.closingAmount,
      'status': _$CashRegisterStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'transactions': instance.transactions,
    };

const _$CashRegisterStatusEnumMap = {
  CashRegisterStatus.open: 'open',
  CashRegisterStatus.closed: 'closed',
  CashRegisterStatus.blocked: 'blocked',
};

CashTransaction _$CashTransactionFromJson(Map<String, dynamic> json) =>
    CashTransaction(
      id: json['id'] as String,
      cashRegisterId: json['cashRegisterId'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String?,
      approvedBy: json['approvedBy'] as String?,
    );

Map<String, dynamic> _$CashTransactionToJson(CashTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cashRegisterId': instance.cashRegisterId,
      'userId': instance.userId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'timestamp': instance.timestamp.toIso8601String(),
      'description': instance.description,
      'approvedBy': instance.approvedBy,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.opening: 'opening',
  TransactionType.closing: 'closing',
  TransactionType.withdrawal: 'withdrawal',
  TransactionType.deposit: 'deposit',
  TransactionType.sangria: 'sangria',
};
