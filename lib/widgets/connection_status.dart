import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';

class ConnectionStatus extends StatelessWidget {
  final SyncService _syncService = Get.find<SyncService>();

  ConnectionStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasConnection = _syncService.hasConnection;
      final pendingSync = _syncService.pendingSyncCount;
      
      if (!hasConnection) {
        return Container(
          color: Colors.red.withOpacity(0.9),
          padding: const EdgeInsets.all(AppTheme.paddingSmall),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: AppTheme.paddingSmall),
              Text(
                'Modo Offline - Os dados serão sincronizados quando houver conexão',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      } else if (pendingSync > 0) {
        return InkWell(
          onTap: () => _showSyncDialog(context),
          child: Container(
            color: Colors.orange.withOpacity(0.9),
            padding: const EdgeInsets.all(AppTheme.paddingSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sync,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: AppTheme.paddingSmall),
                Text(
                  'Existem $pendingSync alterações pendentes. Toque para sincronizar.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      
      return const SizedBox.shrink();
    });
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sincronizar Dados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Existem ${_syncService.pendingSyncCount} alterações pendentes:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            _buildSyncItemCount('Imóveis', _syncService.pendingPropertyCount),
            _buildSyncItemCount('Vistorias', _syncService.pendingInspectionCount),
            _buildSyncItemCount('Clientes', _syncService.pendingClientCount),
            _buildSyncItemCount('Fotos', _syncService.pendingPhotoCount),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Depois'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Get.back();
              await _syncService.syncData();
            },
            icon: const Icon(Icons.sync),
            label: const Text('Sincronizar Agora'),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncItemCount(String label, int count) {
    if (count == 0) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      child: Row(
        children: [
          Icon(
            Icons.fiber_manual_record,
            size: 8,
            color: Get.theme.primaryColor,
          ),
          const SizedBox(width: AppTheme.paddingSmall),
          Text('$count $label'),
        ],
      ),
    );
  }
}
