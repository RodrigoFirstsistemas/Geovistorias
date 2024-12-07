import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/budget_controller.dart';
import '../models/budget_model.dart';
import '../widgets/advanced_search.dart';
import '../theme/app_theme.dart';

class BudgetListScreen extends StatelessWidget {
  final _controller = Get.find<BudgetController>();
  final _searchController = TextEditingController();

  BudgetListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orçamentos'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pendentes'),
              Tab(text: 'Aprovados'),
              Tab(text: 'Rejeitados'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Get.toNamed('/budgets/new'),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: AdvancedSearch(
                searchController: _searchController,
                type: 'budget',
                onSearch: _controller.filterBudgets,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _BudgetList(status: BudgetStatus.pending),
                  _BudgetList(status: BudgetStatus.approved),
                  _BudgetList(status: BudgetStatus.rejected),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetList extends StatelessWidget {
  final BudgetStatus status;
  final _controller = Get.find<BudgetController>();

  _BudgetList({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final budgets = _controller.getBudgetsByStatus(status);
      
      if (budgets.isEmpty) {
        return Center(
          child: Text(
            'Nenhum orçamento ${_getStatusText(status).toLowerCase()}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }

      return ListView.builder(
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final budget = budgets[index];
          return _BudgetCard(budget: budget);
        },
      );
    });
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
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final _controller = Get.find<BudgetController>();

  _BudgetCard({
    Key? key,
    required this.budget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      child: ListTile(
        title: Text('Orçamento #${budget.remoteId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${_controller.getClientName(budget.clientId)}'),
            Text('Valor: R\$ ${budget.totalAmount.toStringAsFixed(2)}'),
            if (budget.status == BudgetStatus.approved)
              Text('Restante: R\$ ${budget.remainingAmount.toStringAsFixed(2)}'),
          ],
        ),
        trailing: _buildTrailingWidget(context),
        onTap: () => Get.toNamed('/budgets/${budget.remoteId}'),
      ),
    );
  }

  Widget _buildTrailingWidget(BuildContext context) {
    switch (budget.status) {
      case BudgetStatus.pending:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => _showApprovalDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _showRejectionDialog(context),
            ),
          ],
        );
      
      case BudgetStatus.approved:
        return IconButton(
          icon: const Icon(Icons.payment),
          onPressed: () => _showPaymentDialog(context),
        );
      
      case BudgetStatus.rejected:
        return const Icon(Icons.block, color: Colors.red);
    }
  }

  void _showApprovalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aprovar Orçamento'),
        content: const Text('Deseja aprovar este orçamento?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.approveBudget(budget.remoteId!);
              Get.back();
            },
            child: const Text('Aprovar'),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(BuildContext context) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeitar Orçamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Por favor, informe o motivo da rejeição:'),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Motivo da rejeição',
              ),
              maxLines: 3,
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
              if (reasonController.text.isNotEmpty) {
                _controller.rejectBudget(
                  budget.remoteId!,
                  reasonController.text,
                );
                Get.back();
              }
            },
            child: const Text('Rejeitar'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    final amountController = TextEditingController();
    final methodController = TextEditingController();
    final dueDateController = TextEditingController();
    
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
                DropdownMenuItem(value: 'pix', child: Text('PIX')),
                DropdownMenuItem(value: 'credit', child: Text('Cartão de Crédito')),
                DropdownMenuItem(value: 'debit', child: Text('Cartão de Débito')),
                DropdownMenuItem(value: 'transfer', child: Text('Transferência')),
                DropdownMenuItem(value: 'cash', child: Text('Dinheiro')),
              ],
              onChanged: (value) => methodController.text = value!,
            ),
            TextField(
              controller: dueDateController,
              decoration: const InputDecoration(
                labelText: 'Data de Vencimento',
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  dueDateController.text = date.toString().split(' ')[0];
                }
              },
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
              if (amountController.text.isNotEmpty &&
                  methodController.text.isNotEmpty &&
                  dueDateController.text.isNotEmpty) {
                _controller.createPaymentOrder(
                  budget.remoteId!,
                  double.parse(amountController.text),
                  methodController.text,
                  DateTime.parse(dueDateController.text),
                );
                Get.back();
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}
