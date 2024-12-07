import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cash_register_controller.dart';
import '../../models/cash_register_model.dart';
import '../../widgets/custom_text_field.dart';

class CashRegisterScreen extends StatelessWidget {
  final cashRegisterController = Get.put(CashRegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciamento de Caixa'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _refreshCashRegister(),
          ),
        ],
      ),
      body: Obx(() {
        if (cashRegisterController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final register = cashRegisterController.currentRegister.value;
        if (register == null) {
          return _buildOpenCashButton();
        }

        return _buildCashRegisterContent(register);
      }),
    );
  }

  Widget _buildOpenCashButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _showOpenCashDialog(),
        icon: Icon(Icons.add),
        label: Text('Abrir Caixa'),
      ),
    );
  }

  Widget _buildCashRegisterContent(CashRegisterModel register) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusCard(register),
          SizedBox(height: 16),
          _buildSummaryCard(),
          SizedBox(height: 16),
          _buildActionButtons(register),
          SizedBox(height: 16),
          _buildTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildStatusCard(CashRegisterModel register) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status do Caixa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status:'),
                _buildStatusChip(register.status),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aberto em:'),
                Text(register.openedAt.toString()),
              ],
            ),
            if (register.closedAt != null) ...[
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fechado em:'),
                  Text(register.closedAt.toString()),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...cashRegisterController.getCashSummary().entries.map(
                  (entry) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          'R\$ ${entry.value.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: entry.key == 'Diferença' && entry.value != 0
                                ? Colors.red
                                : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(CashRegisterModel register) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (register.isOpen) ...[
          ElevatedButton.icon(
            onPressed: () => _showSangriaDialog(register.id),
            icon: Icon(Icons.money_off),
            label: Text('Realizar Sangria'),
          ),
          ElevatedButton.icon(
            onPressed: () => _showCloseCashDialog(register.id),
            icon: Icon(Icons.close),
            label: Text('Fechar Caixa'),
          ),
        ],
        if (!register.isBlocked) ...[
          ElevatedButton.icon(
            onPressed: () => _showBlockDialog(register.id, true),
            icon: Icon(Icons.block),
            label: Text('Bloquear Caixa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ] else ...[
          ElevatedButton.icon(
            onPressed: () => _showBlockDialog(register.id, false),
            icon: Icon(Icons.check_circle),
            label: Text('Desbloquear Caixa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTransactionsList() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Transações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: cashRegisterController.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = cashRegisterController.transactions[index];
                  return ListTile(
                    leading: _getTransactionIcon(transaction.type),
                    title: Text(_getTransactionTitle(transaction.type)),
                    subtitle: Text(transaction.description ?? ''),
                    trailing: Text(
                      'R\$ ${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _getTransactionColor(transaction.type),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }

  Widget _buildStatusChip(CashRegisterStatus status) {
    Color color;
    String label;

    switch (status) {
      case CashRegisterStatus.open:
        color = Colors.green;
        label = 'Aberto';
        break;
      case CashRegisterStatus.closed:
        color = Colors.red;
        label = 'Fechado';
        break;
      case CashRegisterStatus.blocked:
        color = Colors.orange;
        label = 'Bloqueado';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  void _showOpenCashDialog() {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Abrir Caixa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: amountController,
                labelText: 'Valor Inicial',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: notesController,
                labelText: 'Observações',
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancelar'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(amountController.text);
                      if (amount != null) {
                        cashRegisterController.openCashRegister(
                          initialAmount: amount,
                          notes: notesController.text,
                        );
                      }
                    },
                    child: Text('Abrir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCloseCashDialog(String cashRegisterId) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fechar Caixa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: amountController,
                labelText: 'Valor Final',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: notesController,
                labelText: 'Observações',
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancelar'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(amountController.text);
                      if (amount != null) {
                        cashRegisterController.closeCashRegister(
                          cashRegisterId: cashRegisterId,
                          closingAmount: amount,
                          notes: notesController.text,
                        );
                      }
                    },
                    child: Text('Fechar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSangriaDialog(String cashRegisterId) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Realizar Sangria',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: amountController,
                labelText: 'Valor',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: descriptionController,
                labelText: 'Descrição',
                maxLines: 2,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancelar'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(amountController.text);
                      if (amount != null) {
                        cashRegisterController.performSangria(
                          cashRegisterId: cashRegisterId,
                          amount: amount,
                          description: descriptionController.text,
                        );
                      }
                    },
                    child: Text('Confirmar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBlockDialog(String cashRegisterId, bool block) {
    final reasonController = TextEditingController();

    Get.dialog(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                block ? 'Bloquear Caixa' : 'Desbloquear Caixa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: reasonController,
                labelText: 'Motivo',
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancelar'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      cashRegisterController.toggleCashRegisterBlock(
                        cashRegisterId: cashRegisterId,
                        blocked: block,
                        reason: reasonController.text,
                      );
                    },
                    child: Text(block ? 'Bloquear' : 'Desbloquear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: block ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshCashRegister() {
    final register = cashRegisterController.currentRegister.value;
    if (register != null) {
      cashRegisterController.loadCashRegister(register.id);
    }
  }

  Icon _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.opening:
        return Icon(Icons.login, color: Colors.green);
      case TransactionType.closing:
        return Icon(Icons.logout, color: Colors.red);
      case TransactionType.withdrawal:
        return Icon(Icons.remove_circle, color: Colors.red);
      case TransactionType.deposit:
        return Icon(Icons.add_circle, color: Colors.green);
      case TransactionType.sangria:
        return Icon(Icons.money_off, color: Colors.orange);
    }
  }

  String _getTransactionTitle(TransactionType type) {
    switch (type) {
      case TransactionType.opening:
        return 'Abertura';
      case TransactionType.closing:
        return 'Fechamento';
      case TransactionType.withdrawal:
        return 'Saída';
      case TransactionType.deposit:
        return 'Entrada';
      case TransactionType.sangria:
        return 'Sangria';
    }
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.opening:
      case TransactionType.deposit:
        return Colors.green;
      case TransactionType.closing:
      case TransactionType.withdrawal:
      case TransactionType.sangria:
        return Colors.red;
    }
  }
}
