import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'budget_model.g.dart';

@JsonSerializable()
@Collection()
class Budget {
  Id id = Isar.autoIncrement;
  
  @Index(type: IndexType.value)
  String? remoteId;
  
  String clientId;
  String propertyId;
  String inspectionId;
  DateTime createdAt;
  DateTime? updatedAt;
  double totalAmount;
  String description;
  List<BudgetItem> items;
  
  @Enumerated(EnumType.name)
  BudgetStatus status;
  
  String? rejectionReason;
  DateTime? approvedAt;
  String? approvedBy;
  
  // Informações de pagamento
  List<PaymentOrder> paymentOrders;
  double paidAmount;
  double remainingAmount;
  
  // Campos de controle
  bool needsSync;
  DateTime? lastSyncAt;

  Budget({
    required this.clientId,
    required this.propertyId,
    required this.inspectionId,
    required this.totalAmount,
    required this.description,
    required this.items,
    this.status = BudgetStatus.pending,
    this.paymentOrders = const [],
    this.paidAmount = 0,
    this.needsSync = true,
  })  : createdAt = DateTime.now(),
        remainingAmount = totalAmount;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetToJson(this);

  factory Budget.create({
    required String clientId,
    required String propertyId,
    required String inspectionId,
    required double totalAmount,
    required String description,
    required List<BudgetItem> items,
  }) {
    final now = DateTime.now();
    return Budget(
      clientId: clientId,
      propertyId: propertyId,
      inspectionId: inspectionId,
      totalAmount: totalAmount,
      description: description,
      items: items,
      paymentOrders: [],
      paidAmount: 0,
      createdAt: now,
      updatedAt: now,
      needsSync: true,
    );
  }

  // Métodos de negócio
  void approve(String approver) {
    status = BudgetStatus.approved;
    approvedAt = DateTime.now();
    approvedBy = approver;
    updatedAt = DateTime.now();
    needsSync = true;
  }

  void reject(String reason) {
    status = BudgetStatus.rejected;
    rejectionReason = reason;
    updatedAt = DateTime.now();
    needsSync = true;
  }

  PaymentOrder createPaymentOrder({
    required double amount,
    required String method,
    required DateTime dueDate,
  }) {
    if (status != BudgetStatus.approved) {
      throw Exception('Não é possível criar ordem de pagamento para orçamento não aprovado');
    }

    if (amount > remainingAmount) {
      throw Exception('Valor maior que o saldo restante');
    }

    final paymentOrder = PaymentOrder(
      id: '',
      budgetId: remoteId!,
      amount: amount,
      method: method,
      dueDate: dueDate,
      status: PaymentStatus.pending,
    );

    paymentOrders.add(paymentOrder);
    remainingAmount -= amount;
    updatedAt = DateTime.now();
    needsSync = true;

    return paymentOrder;
  }

  void confirmPayment(String paymentOrderId) {
    final paymentOrder = paymentOrders.firstWhere((p) => p.id == paymentOrderId);
    paymentOrder.confirm();
    paidAmount += paymentOrder.amount!;
    updatedAt = DateTime.now();
    needsSync = true;
  }
}

@JsonSerializable()
@embedded
class BudgetItem {
  String? description;
  int? quantity;
  double? unitPrice;
  late double totalPrice;

  BudgetItem({
    this.description,
    this.quantity,
    this.unitPrice,
  }) {
    totalPrice = (quantity ?? 0) * (unitPrice ?? 0);
  }

  factory BudgetItem.fromJson(Map<String, dynamic> json) => _$BudgetItemFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetItemToJson(this);
}

@JsonSerializable()
@embedded
class PaymentOrder {
  String id;
  String? budgetId;
  double? amount;
  String? method;
  DateTime? dueDate;
  DateTime? paidAt;
  
  @Enumerated(EnumType.name)
  PaymentStatus? status;
  
  String? transactionId;
  String? receipt;

  PaymentOrder({
    this.id = '',
    this.budgetId,
    this.amount,
    this.method,
    this.dueDate,
    this.status,
  }) {
    if (id.isEmpty) {
      id = DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  factory PaymentOrder.fromJson(Map<String, dynamic> json) => _$PaymentOrderFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentOrderToJson(this);

  void confirm({String? transactionId, String? receipt}) {
    status = PaymentStatus.paid;
    paidAt = DateTime.now();
    this.transactionId = transactionId;
    this.receipt = receipt;
  }
}

@JsonEnum()
enum BudgetStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
}

@JsonEnum()
enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('paid')
  paid,
  @JsonValue('cancelled')
  cancelled,
}
