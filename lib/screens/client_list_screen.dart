import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/base_layout.dart';
import '../theme/app_theme.dart';

class ClientListScreen extends StatelessWidget {
  ClientListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Clientes',
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar adição de cliente
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseCard(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Buscar clientes...',
                    ),
                    onChanged: (value) {
                      // TODO: Implementar busca
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMedium),
                DropdownButton<String>(
                  value: 'todos',
                  items: [
                    DropdownMenuItem(
                      value: 'todos',
                      child: Text('Todos'),
                    ),
                    DropdownMenuItem(
                      value: 'ativos',
                      child: Text('Ativos'),
                    ),
                    DropdownMenuItem(
                      value: 'inativos',
                      child: Text('Inativos'),
                    ),
                  ],
                  onChanged: (value) {
                    // TODO: Implementar filtro
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Expanded(
            child: BaseCard(
              child: ListView.builder(
                itemCount: 10, // TODO: Usar dados reais
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Text(
                        'JS',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text('João Silva'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('(21) 99999-9999'),
                        Text('joao.silva@email.com'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: AppTheme.paddingSmall),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: AppTheme.paddingSmall),
                              Text('Excluir'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            Get.toNamed('/client/${index + 1}');
                            break;
                          case 'delete':
                            _showDeleteDialog(context);
                            break;
                        }
                      },
                    ),
                    onTap: () => Get.toNamed('/client/${index + 1}'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Cliente'),
        content: const Text('Tem certeza que deseja excluir este cliente?'),
        actions: BaseActionButtons(
          children: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implementar exclusão
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Excluir'),
            ),
          ],
        ),
      ),
    );
  }
}
