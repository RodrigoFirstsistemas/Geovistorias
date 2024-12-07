import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/base_layout.dart';
import '../theme/app_theme.dart';

class InspectionDetailScreen extends StatelessWidget {
  final String inspectionId = Get.parameters['id'] ?? '';

  InspectionDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Detalhes da Vistoria',
      actions: [
        ReportOptions(
          title: 'Vistoria',
          type: 'inspection',
          data: {}, // TODO: Adicionar dados da vistoria
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showEditDialog(context),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _showDeleteDialog(context),
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações Gerais',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildInfoRow(context, 'Status:', 'Em andamento'),
                  _buildInfoRow(context, 'Data:', '06/12/2024'),
                  _buildInfoRow(context, 'Responsável:', 'João Silva'),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Imóvel',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildInfoRow(context, 'Tipo:', 'Apartamento'),
                  _buildInfoRow(context, 'Endereço:', 'Rua das Flores, 123'),
                  _buildInfoRow(context, 'Proprietário:', 'Maria Santos'),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Checklist',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildChecklistItem(
                    context,
                    'Estrutura',
                    'Verificar paredes, teto e piso',
                    true,
                  ),
                  _buildChecklistItem(
                    context,
                    'Elétrica',
                    'Verificar tomadas e iluminação',
                    true,
                  ),
                  _buildChecklistItem(
                    context,
                    'Hidráulica',
                    'Verificar torneiras e registros',
                    false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fotos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: AppTheme.paddingSmall),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: InkWell(
                              onTap: () {
                                // TODO: Implementar visualização da foto
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                ),
                                child: Icon(
                                  Icons.photo,
                                  color: Theme.of(context).primaryColor,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implementar adição de foto
                      },
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Adicionar Foto'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Observações',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  TextField(
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Digite suas observações...',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implementar finalização da vistoria
        },
        icon: const Icon(Icons.check),
        label: const Text('Finalizar Vistoria'),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: AppTheme.paddingSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
    BuildContext context,
    String title,
    String description,
    bool isChecked,
  ) {
    return CheckboxListTile(
      value: isChecked,
      onChanged: (value) {
        // TODO: Implementar alteração do status
      },
      title: Text(title),
      subtitle: Text(description),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Vistoria'),
        content: SingleChildScrollView(
          child: BaseForm(
            children: [
              DropdownButtonFormField<String>(
                value: 'em_andamento',
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  DropdownMenuItem(
                    value: 'em_andamento',
                    child: Text('Em andamento'),
                  ),
                  DropdownMenuItem(
                    value: 'concluida',
                    child: Text('Concluída'),
                  ),
                  DropdownMenuItem(
                    value: 'cancelada',
                    child: Text('Cancelada'),
                  ),
                ],
                onChanged: (value) {
                  // TODO: Implementar alteração do status
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Responsável'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Data'),
              ),
            ],
          ),
        ),
        actions: BaseActionButtons(
          children: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implementar edição
                Get.back();
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Vistoria'),
        content: const Text('Tem certeza que deseja excluir esta vistoria?'),
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
