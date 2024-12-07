import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/base_layout.dart';
import '../theme/app_theme.dart';
import '../controllers/property_controller.dart';

class DashboardScreen extends StatelessWidget {
  final PropertyController _propertyController = Get.find<PropertyController>();

  DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Dashboard',
      showBackButton: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visão Geral',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          BaseForm(
            columns: 3,
            children: [
              _buildStatCard(
                context,
                icon: Icons.home,
                title: 'Imóveis',
                value: '0',
                color: Colors.blue,
                onTap: () => Get.toNamed('/properties'),
              ),
              _buildStatCard(
                context,
                icon: Icons.assignment,
                title: 'Vistorias',
                value: '0',
                color: Colors.green,
                onTap: () => Get.toNamed('/inspections'),
              ),
              _buildStatCard(
                context,
                icon: Icons.people,
                title: 'Clientes',
                value: '0',
                color: Colors.orange,
                onTap: () => Get.toNamed('/clients'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingXLarge),
          Text(
            'Atividades Recentes',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          Expanded(
            child: BaseCard(
              child: ListView(
                children: [
                  _buildActivityItem(
                    context,
                    icon: Icons.home,
                    title: 'Novo Imóvel Cadastrado',
                    description: 'Casa em Copacabana',
                    time: '2 horas atrás',
                  ),
                  _buildActivityItem(
                    context,
                    icon: Icons.assignment,
                    title: 'Vistoria Realizada',
                    description: 'Apartamento em Ipanema',
                    time: '3 horas atrás',
                  ),
                  _buildActivityItem(
                    context,
                    icon: Icons.people,
                    title: 'Novo Cliente',
                    description: 'João Silva',
                    time: '5 horas atrás',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BaseCard(
      onTap: onTap,
      color: color.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppTheme.paddingSmall),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String time,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(title),
      subtitle: Text(description),
      trailing: Text(
        time,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
