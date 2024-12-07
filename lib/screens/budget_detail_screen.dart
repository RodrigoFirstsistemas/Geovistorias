import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/budget_controller.dart';
import '../models/budget_model.dart';
import '../theme/app_theme.dart';

class BudgetDetailScreen extends StatelessWidget {
  final String budgetId = Get.parameters['id']!;
  final _controller = Get.find<BudgetController>();

  BudgetDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orçamento #$budgetId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed('/budgets/$budgetId/edit'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Excluir'),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Text('Compartilhar'),
              ),
              const PopupMenuItem(
                value: 'print',
                child: Text('Imprimir'),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        final budget = _controller.getBudget(budgetId);
        if (budget == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(budget),
              const SizedBox(height: AppTheme.paddingMedium),
              _buildClientInfo(budget),
              const SizedBox(height: AppTheme.paddingMedium),
              _buildItemsList(budget),
              const SizedBox(height: AppTheme.paddingMedium),
              if (budget.status == BudgetStatus.approved)
                _buildPaymentOrders(budget),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() {
        final budget = _controller.getBudget(budgetId);
        if (budget?.status == BudgetStatus.approved) {
          return FloatingActionButton.extended(
            onPressed: () => _showPaymentDialog(context, budget!),
            icon: const Icon(Icons.payment),
            label: const Text('Nova Ordem de Pagamento'),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildStatusCard(Budget budget) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${_getStatusText(budget.status)}',
                  style: Get.textTheme.titleMedium,
                ),
                _buildStatusIcon(budget.status),
              ],
            ),
            const Divider(),
            Text(
              'Valor Total: R\$ ${budget.totalAmount.toStringAsFixed(2)}',
              style: Get.textTheme.titleMedium,
            ),
            if (budget.status == BudgetStatus.approved) ...[
              Text(
                'Valor Pago: R\$ ${budget.paidAmount.toStringAsFixed(2)}',
                style: Get.textTheme.bodyLarge,
              ),
              Text(
                'Valor Restante: R\$ ${budget.remainingAmount.toStringAsFixed(2)}',
                style: Get.textTheme.bodyLarge,
              ),
            ],
            if (budget.status == BudgetStatus.rejected)
              Text(
                'Motivo: ${budget.rejectionReason}',
                style: Get.textTheme.bodyLarge?.copyWith(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfo(Budget budget) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Cliente',
              style: Get.textTheme.titleMedium,
            ),
            const Divider(),
            Text(
              'Cliente: ${_controller.getClientName(budget.clientId)}',
              style: Get.textTheme.bodyLarge,
            ),
            Text(
              'Imóvel: ${_controller.getPropertyAddress(budget.propertyId)}',
              style: Get.textTheme.bodyLarge,
            ),
            Text(
              'Vistoria: ${_controller.getInspectionDate(budget.inspectionId)}',
              style: Get.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(Budget budget) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Itens do Orçamento',
              style: Get.textTheme.titleMedium,
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: budget.items.length,
              itemBuilder: (context, index) {
                final item = budget.items[index];
                return ListTile(
                  title: Text(item.description),
                  subtitle: Text(
                    '${item.quantity} x R\$ ${item.unitPrice.toStringAsFixed(2)}',
                  ),
                  trailing: Text(
                    'R\$ ${item.totalPrice.toStringAsFixed(2)}',
                    style: Get.textTheme.titleMedium,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOrders(Budget budget) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ordens de Pagamento',
              style: Get.textTheme.titleMedium,
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: budget.paymentOrders.length,
              itemBuilder: (context, index) {
                final order = budget.paymentOrders[index];
                return ListTile(
                  title: Text('Ordem #${order.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Valor: R\$ ${order.amount.toStringAsFixed(2)}'),
                      Text('Vencimento: ${_formatDate(order.dueDate)}'),
                      Text('Método: ${_getPaymentMethod(order.method)}'),
                    ],
                  ),
                  trailing: _buildPaymentOrderStatus(order),
                  onTap: order.status == PaymentStatus.pending
                      ? () => _showConfirmPaymentDialog(context, order)
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.pending:
        return const Icon(Icons.pending, color: Colors.orange);
      case BudgetStatus.approved:
        return const Icon(Icons.check_circle, color: Colors.green);
      case BudgetStatus.rejected:
        return const Icon(Icons.cancel, color: Colors.red);
    }
  }

  Widget _buildPaymentOrderStatus(PaymentOrder order) {
    switch (order.status) {
      case PaymentStatus.pending:
        return Chip(
          label: const Text('Pendente'),
          backgroundColor: Colors.orange[100],
          labelStyle: TextStyle(color: Colors.orange[900]),
        );
      case PaymentStatus.paid:
        return Chip(
          label: const Text('Pago'),
          backgroundColor: Colors.green[100],
          labelStyle: TextStyle(color: Colors.green[900]),
        );
      case PaymentStatus.cancelled:
        return Chip(
          label: const Text('Cancelado'),
          backgroundColor: Colors.red[100],
          labelStyle: TextStyle(color: Colors.red[900]),
        );
    }
  }

  String _getStatusText(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.pending:
        return 'Pendente';
      case BudgetStatus.approved:
        return 'Aprovado';
      case BudgetStatus.rejected:
        return 'Rejeitado';
    }
  }

  String _getPaymentMethod(String method) {
    switch (method) {
      case 'pix':
        return 'PIX';
      case 'credit':
        return 'Cartão de Crédito';
      case 'debit':
        return 'Cartão de Débito';
      case 'transfer':
        return 'Transferência';
      case 'cash':
        return 'Dinheiro';
      default:
        return method;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'delete':
        _showDeleteDialog(context);
        break;
      case 'share':
        _controller.shareBudget(budgetId);
        break;
      case 'print':
        _controller.printBudget(budgetId);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Orçamento'),
        content: const Text(
          'Tem certeza que deseja excluir este orçamento? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.deleteBudget(budgetId);
              Get.back();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, Budget budget) {
    final amountController = TextEditingController();
    final methodController = TextEditingController();
    final installmentsController = TextEditingController();
    final stonePaymentService = Get.find<StonePaymentService>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Ordem de Pagamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
              ),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: methodController.text.isEmpty ? null : methodController.text,
              decoration: const InputDecoration(
                labelText: 'Forma de Pagamento',
              ),
              items: const [
                DropdownMenuItem(value: 'credit', child: Text('Cartão de Crédito')),
                DropdownMenuItem(value: 'debit', child: Text('Cartão de Débito')),
                DropdownMenuItem(value: 'pix', child: Text('PIX')),
                DropdownMenuItem(value: 'transfer', child: Text('Transferência')),
                DropdownMenuItem(value: 'cash', child: Text('Dinheiro')),
              ],
              onChanged: (value) {
                methodController.text = value!;
                // Mostrar campo de parcelas apenas para cartão de crédito
                if (value == 'credit') {
                  showInstallmentsField.value = true;
                } else {
                  showInstallmentsField.value = false;
                  installmentsController.text = '1';
                }
              },
            ),
            Obx(() {
              if (showInstallmentsField.value) {
                return DropdownButtonFormField<String>(
                  value: installmentsController.text.isEmpty ? '1' : installmentsController.text,
                  decoration: const InputDecoration(
                    labelText: 'Parcelas',
                  ),
                  items: List.generate(12, (index) => index + 1).map((i) {
                    return DropdownMenuItem(
                      value: i.toString(),
                      child: Text('$i${i == 1 ? ' vez' : ' vezes'}'),
                    );
                  }).toList(),
                  onChanged: (value) => installmentsController.text = value!,
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (amountController.text.isNotEmpty &&
                  methodController.text.isNotEmpty) {
                final amount = double.parse(amountController.text);
                final method = methodController.text;
                final installments = installmentsController.text;

                // Se for pagamento com cartão, usar Stone SDK
                if (method == 'credit' || method == 'debit') {
                  try {
                    final result = await stonePaymentService.makePayment(
                      amount: amount,
                      orderId: budget.remoteId!,
                      installments: installments,
                      paymentType: method,
                    );

                    // Criar ordem de pagamento com os dados da transação
                    _controller.createPaymentOrder(
                      budgetId,
                      amount,
                      method,
                      DateTime.now(),
                      transactionId: result['transactionId'],
                      receipt: 'Stone Transaction ID: ${result['transactionId']}',
                    );

                    // Imprimir comprovante
                    await stonePaymentService.printReceipt(result['transactionId']);

                    Get.back();
                    Get.snackbar(
                      'Sucesso',
                      'Pagamento processado com sucesso!',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    Get.back();
                    Get.snackbar(
                      'Erro',
                      'Erro ao processar pagamento: ${e.toString()}',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                } else {
                  // Para outros métodos, criar ordem de pagamento normal
                  _controller.createPaymentOrder(
                    budgetId,
                    amount,
                    method,
                    DateTime.now(),
                  );
                  Get.back();
                }
              }
            },
            child: const Text('Processar Pagamento'),
          ),
        ],
      ),
    );
  }

  void _showConfirmPaymentDialog(BuildContext context, PaymentOrder order) {
    final transactionController = TextEditingController();
    final receiptController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Pagamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Valor: R\$ ${order.amount.toStringAsFixed(2)}',
              style: Get.textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            TextField(
              controller: transactionController,
              decoration: const InputDecoration(
                labelText: 'ID da Transação (opcional)',
              ),
            ),
            TextField(
              controller: receiptController,
              decoration: const InputDecoration(
                labelText: 'Comprovante (opcional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.confirmPayment(
                budgetId,
                order.id,
                transactionController.text,
                receiptController.text,
              );
              Get.back();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
