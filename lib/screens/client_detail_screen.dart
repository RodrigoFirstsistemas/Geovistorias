import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/base_layout.dart';
import '../theme/app_theme.dart';

class ClientDetailScreen extends StatelessWidget {
  final String clientId = Get.parameters['id'] ?? '';

  ClientDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Detalhes do Cliente',
      actions: [
        ReportOptions(
          title: 'Cliente',
          type: 'client',
          data: {}, // TODO: Adicionar dados do cliente
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
                    'Informações Pessoais',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildInfoRow(context, 'Nome:', 'João Silva'),
                  _buildInfoRow(context, 'CPF:', '123.456.789-00'),
                  _buildInfoRow(context, 'RG:', '12.345.678-9'),
                  _buildInfoRow(context, 'Data de Nascimento:', '01/01/1980'),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contato',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildInfoRow(context, 'Telefone:', '(21) 99999-9999'),
                  _buildInfoRow(context, 'Email:', 'joao.silva@email.com'),
                  _buildInfoRow(context, 'WhatsApp:', '(21) 99999-9999'),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Endereço',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildInfoRow(context, 'CEP:', '12.345-678'),
                  _buildInfoRow(context, 'Rua:', 'Rua das Flores'),
                  _buildInfoRow(context, 'Número:', '123'),
                  _buildInfoRow(context, 'Complemento:', 'Apto 101'),
                  _buildInfoRow(context, 'Bairro:', 'Centro'),
                  _buildInfoRow(context, 'Cidade:', 'Rio de Janeiro'),
                  _buildInfoRow(context, 'Estado:', 'RJ'),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Imóveis',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implementar adição de imóvel
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3, // TODO: Usar dados reais
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.home),
                        title: Text('Apartamento em Copacabana'),
                        subtitle: Text('Rua das Flores, 123'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => Get.toNamed('/property/$index'),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            BaseCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vistorias',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implementar adição de vistoria
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 2, // TODO: Usar dados reais
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.assignment),
                        title: Text('Vistoria #${index + 1}'),
                        subtitle: Text('06/12/2024'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => Get.toNamed('/inspection/$index'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Cliente'),
        content: SingleChildScrollView(
          child: BaseForm(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'CPF'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'RG'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Data de Nascimento'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Telefone'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'WhatsApp'),
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
