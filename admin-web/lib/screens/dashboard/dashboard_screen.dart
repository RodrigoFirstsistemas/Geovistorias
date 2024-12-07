import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../layouts/admin_layout.dart';
import '../../controllers/dashboard_controller.dart';
import 'widgets/stat_card.dart';
import 'widgets/chart_card.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      selectedRoute: '/dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatCards(),
            const SizedBox(height: 24),
            _buildCharts(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Get.textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Obx(() => Text(
              'Última atualização: ${controller.lastUpdate}',
              style: Get.textTheme.bodySmall,
            )),
          ],
        ),
        ElevatedButton.icon(
          onPressed: controller.refreshData,
          icon: const Icon(Icons.refresh),
          label: const Text('Atualizar'),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Obx(() => GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatCard(
          title: 'Terminais Ativos',
          value: controller.activeTerminals.toString(),
          icon: Icons.point_of_sale,
          color: Colors.blue,
          trend: 5,
        ),
        StatCard(
          title: 'Vistorias Hoje',
          value: controller.todayInspections.toString(),
          icon: Icons.assignment,
          color: Colors.green,
          trend: 12,
        ),
        StatCard(
          title: 'Orçamentos Pendentes',
          value: controller.pendingBudgets.toString(),
          icon: Icons.attach_money,
          color: Colors.orange,
          trend: -3,
        ),
        StatCard(
          title: 'Pagamentos Hoje',
          value: 'R\$ ${controller.todayPayments}',
          icon: Icons.payment,
          color: Colors.purple,
          trend: 8,
        ),
      ],
    ));
  }

  Widget _buildCharts() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ChartCard(
            title: 'Vistorias por Período',
            chart: LineChart(controller.inspectionsChartData),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ChartCard(
            title: 'Status dos Terminais',
            chart: PieChart(controller.terminalsChartData),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atividade Recente',
              style: Get.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentActivities.length,
              itemBuilder: (context, index) {
                final activity = controller.recentActivities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: activity.color.withOpacity(0.2),
                    child: Icon(activity.icon, color: activity.color),
                  ),
                  title: Text(activity.title),
                  subtitle: Text(activity.description),
                  trailing: Text(
                    activity.time,
                    style: Get.textTheme.bodySmall,
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
