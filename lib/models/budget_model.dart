import 'package:isar/isar.dart';

@collection
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
    paidAmount += paymentOrder.amount;
    updatedAt = DateTime.now();
    needsSync = true;
  }
}

@embedded
class BudgetItem {
  String description;
  int quantity;
  double unitPrice;
  double totalPrice;

  BudgetItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  }) : totalPrice = quantity * unitPrice;
}

@embedded
class PaymentOrder {
  String id;
  String budgetId;
  double amount;
  String method;
  DateTime dueDate;
  DateTime? paidAt;
  
  @Enumerated(EnumType.name)
  PaymentStatus status;
  
  String? transactionId;
  String? receipt;

  PaymentOrder({
    String? id,
    required this.budgetId,
    required this.amount,
    required this.method,
    required this.dueDate,
    required this.status,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  void confirm({String? transactionId, String? receipt}) {
    status = PaymentStatus.paid;
    paidAt = DateTime.now();
    this.transactionId = transactionId;
    this.receipt = receipt;
  }
}

enum BudgetStatus {
  pending,
  approved,
  rejected,
}

enum PaymentStatus {
  pending,
  paid,
  cancelled,
}
