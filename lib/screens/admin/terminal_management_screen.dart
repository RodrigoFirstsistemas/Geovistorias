import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/terminal_controller.dart';
import '../../models/terminal_model.dart';
import '../../widgets/advanced_search.dart';
import '../../theme/app_theme.dart';

class TerminalManagementScreen extends StatelessWidget {
  final _controller = Get.find<TerminalController>();
  final _searchController = TextEditingController();

  TerminalManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gerenciamento de Terminais'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pendentes'),
              Tab(text: 'Aprovados'),
              Tab(text: 'Rejeitados'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: AdvancedSearch(
                searchController: _searchController,
                type: 'terminal',
                onSearch: _controller.filterTerminals,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _TerminalList(status: TerminalStatus.pending),
                  _TerminalList(status: TerminalStatus.approved),
                  _TerminalList(status: TerminalStatus.rejected),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TerminalList extends StatelessWidget {
  final TerminalStatus status;
  final _controller = Get.find<TerminalController>();

  _TerminalList({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final terminals = _controller.getTerminalsByStatus(status);
      
      if (terminals.isEmpty) {
        return Center(
          child: Text(
            'Nenhum terminal ${_getStatusText(status).toLowerCase()}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }

      return ListView.builder(
        itemCount: terminals.length,
        itemBuilder: (context, index) {
          final terminal = terminals[index];
          return _TerminalCard(terminal: terminal);
        },
      );
    });
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
}

class _TerminalCard extends StatelessWidget {
  final Terminal terminal;
  final _controller = Get.find<TerminalController>();

  _TerminalCard({
    Key? key,
    required this.terminal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      child: ExpansionTile(
        title: Text('Terminal #${terminal.terminalNumber}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usuário: ${terminal.userName}'),
            Text('Email: ${terminal.userEmail}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Número de Série', terminal.serialNumber),
                _buildInfoRow('Stone Code', terminal.stoneCode),
                _buildInfoRow('Telefone', terminal.userPhone),
                _buildInfoRow('Registrado em', _formatDate(terminal.registeredAt)),
                if (terminal.approvedAt != null)
                  _buildInfoRow('Aprovado em', _formatDate(terminal.approvedAt!)),
                if (terminal.lastAccessAt != null)
                  _buildInfoRow('Último acesso', _formatDate(terminal.lastAccessAt!)),
                if (terminal.rejectionReason != null)
                  _buildInfoRow('Motivo da rejeição', terminal.rejectionReason!),
                const SizedBox(height: AppTheme.paddingMedium),
                _buildActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    switch (terminal.status) {
      case TerminalStatus.pending:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => _showRejectionDialog(context),
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text('Rejeitar'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            ElevatedButton.icon(
              onPressed: () => _showApprovalDialog(context),
              icon: const Icon(Icons.check),
              label: const Text('Aprovar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      
      case TerminalStatus.approved:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => _showBlockDialog(context),
              icon: const Icon(Icons.block),
              label: const Text('Bloquear'),
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            ElevatedButton.icon(
              onPressed: () => _showConfigureDialog(context),
              icon: const Icon(Icons.settings),
              label: const Text('Configurar Stone'),
            ),
          ],
        );
      
      case TerminalStatus.rejected:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () => _showApprovalDialog(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Reavaliar'),
            ),
          ],
        );
      
      case TerminalStatus.blocked:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () => _controller.unblockTerminal(terminal.remoteId!),
              icon: const Icon(Icons.lock_open),
              label: const Text('Desbloquear'),
            ),
          ],
        );
    }
  }

  void _showApprovalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aprovar Terminal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Confirma a aprovação deste terminal?'),
            const SizedBox(height: AppTheme.paddingMedium),
            _buildInfoRow('Terminal', terminal.terminalNumber),
            _buildInfoRow('Usuário', terminal.userName),
            _buildInfoRow('Email', terminal.userEmail),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.approveTerminal(terminal.remoteId!);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
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
        title: const Text('Rejeitar Terminal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Por favor, informe o motivo da rejeição:'),
            const SizedBox(height: AppTheme.paddingMedium),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                hintText: 'Informe o motivo da rejeição',
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
                _controller.rejectTerminal(
                  terminal.remoteId!,
                  reasonController.text,
                );
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rejeitar'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(BuildContext context) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquear Terminal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Por favor, informe o motivo do bloqueio:'),
            const SizedBox(height: AppTheme.paddingMedium),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                hintText: 'Informe o motivo do bloqueio',
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
                _controller.blockTerminal(
                  terminal.remoteId!,
                  reasonController.text,
                );
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
  }

  void _showConfigureDialog(BuildContext context) {
    final packagecloudTokenController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar Stone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Configure as credenciais da Stone para este terminal:'),
            const SizedBox(height: AppTheme.paddingMedium),
            TextField(
              controller: packagecloudTokenController,
              decoration: const InputDecoration(
                labelText: 'Packagecloud Token',
                hintText: 'Insira o token do Packagecloud',
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
              if (packagecloudTokenController.text.isNotEmpty) {
                _controller.configureStone(
                  terminal.remoteId!,
                  packagecloudTokenController.text,
                );
                Get.back();
              }
            },
            child: const Text('Configurar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
