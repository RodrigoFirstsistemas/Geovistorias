import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../layouts/admin_layout.dart';
import '../../controllers/terminals_controller.dart';
import '../../models/terminal_model.dart';

class TerminalsScreen extends GetView<TerminalsController> {
  const TerminalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      selectedRoute: '/terminals',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildFilters(),
              const Divider(),
              Expanded(
                child: _buildTerminalsTable(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Gerenciamento de Terminais',
            style: Get.textTheme.headlineSmall,
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _exportTerminals(),
                icon: const Icon(Icons.download),
                label: const Text('Exportar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddTerminalDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Novo Terminal'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar terminais...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: controller.onSearchChanged,
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<TerminalStatus>(
            value: controller.selectedStatus.value,
            items: TerminalStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(_getStatusText(status)),
              );
            }).toList(),
            onChanged: controller.onStatusChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalsTable() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return DataTable2(
        columns: const [
          DataColumn2(
            label: Text('Terminal'),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text('Usuário'),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text('Status'),
            size: ColumnSize.S,
          ),
          DataColumn2(
            label: Text('Último Acesso'),
            size: ColumnSize.M,
          ),
          DataColumn2(
            label: Text('Ações'),
            size: ColumnSize.S,
          ),
        ],
        rows: controller.filteredTerminals.map((terminal) {
          return DataRow2(
            cells: [
              DataCell(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(terminal.terminalNumber),
                  Text(
                    terminal.serialNumber,
                    style: Get.textTheme.bodySmall,
                  ),
                ],
              )),
              DataCell(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(terminal.userName),
                  Text(
                    terminal.userEmail,
                    style: Get.textTheme.bodySmall,
                  ),
                ],
              )),
              DataCell(_buildStatusBadge(terminal.status)),
              DataCell(Text(terminal.lastAccessAt?.toString() ?? '-')),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditTerminalDialog(terminal),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteConfirmation(terminal),
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      );
    });
  }

  Widget _buildStatusBadge(TerminalStatus status) {
    Color color;
    switch (status) {
      case TerminalStatus.pending:
        color = Colors.orange;
        break;
      case TerminalStatus.approved:
        color = Colors.green;
        break;
      case TerminalStatus.rejected:
        color = Colors.red;
        break;
      case TerminalStatus.blocked:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(color: color),
      ),
    );
  }

  String _getStatusText(TerminalStatus status) {
    switch (status) {
      case TerminalStatus.pending:
        return 'Pendente';
      case TerminalStatus.approved:
        return 'Aprovado';
      case TerminalStatus.rejected:
        return 'Rejeitado';
      case TerminalStatus.blocked:
        return 'Bloqueado';
    }
  }

  void _showAddTerminalDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Novo Terminal',
                style: Get.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              // Formulário aqui
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTerminalDialog(Terminal terminal) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar Terminal',
                style: Get.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              // Formulário aqui
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Terminal terminal) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o terminal ${terminal.terminalNumber}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteTerminal(terminal);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _exportTerminals() {
    // Implementar exportação
  }
}
