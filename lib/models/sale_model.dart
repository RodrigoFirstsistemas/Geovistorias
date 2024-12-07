import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sale_model.g.dart';

@JsonSerializable()
@Collection()
class SaleModel {
  Id id = Isar.autoIncrement;
  
  @Index(type: IndexType.value)
  String? remoteId;
  
  String clientId;
  String? budgetId;
  String description;
  double total;
  double? discount;
  double paid;
  SaleStatus status;
  String? cancelReason;
  String? canceledBy;
  DateTime? canceledAt;
  List<PaymentItem> payments;
  DateTime createdAt;
  DateTime updatedAt;
  String createdBy;
  bool needsSync;
  int printCount;

  SaleModel({
    this.remoteId,
    required this.clientId,
    this.budgetId,
    required this.description,
    required this.total,
    this.discount,
    required this.paid,
    required this.status,
    this.cancelReason,
    this.canceledBy,
    this.canceledAt,
    required this.payments,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.needsSync = true,
    this.printCount = 0,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) => _$SaleModelFromJson(json);
  Map<String, dynamic> toJson() => _$SaleModelToJson(this);

  factory SaleModel.create({
    required String clientId,
    String? budgetId,
    required String description,
    required double total,
    double? discount,
    required List<PaymentItem> payments,
    required String createdBy,
  }) {
    final now = DateTime.now();
    final paid = payments.fold(0.0, (sum, payment) => sum + payment.amount);
    
    return SaleModel(
      clientId: clientId,
      budgetId: budgetId,
      description: description,
      total: total,
      discount: discount,
      paid: paid,
      status: paid >= total ? SaleStatus.completed : SaleStatus.pending,
      payments: payments,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      needsSync: true,
      printCount: 0,
    );
  }

  void cancel({required String reason, required String userId}) {
    if (status == SaleStatus.cancelled) {
      throw Exception('Venda já está cancelada');
    }
    
    status = SaleStatus.cancelled;
    cancelReason = reason;
    canceledBy = userId;
    canceledAt = DateTime.now();
    updatedAt = DateTime.now();
    needsSync = true;
  }

  void addPayment(PaymentItem payment) {
    payments.add(payment);
    paid += payment.amount;
    if (paid >= total) {
      status = SaleStatus.completed;
    }
    updatedAt = DateTime.now();
    needsSync = true;
  }

  void incrementPrintCount() {
    printCount++;
    updatedAt = DateTime.now();
    needsSync = true;
  }
}

@JsonSerializable()
class PaymentItem {
  String type;
  double amount;
  String? transactionId;
  DateTime date;
  String? receipt;
  String receivedBy;

  PaymentItem({
    required this.type,
    required this.amount,
    this.transactionId,
    required this.date,
    this.receipt,
    required this.receivedBy,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) => _$PaymentItemFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentItemToJson(this);
}

@JsonEnum()
enum SaleStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}
