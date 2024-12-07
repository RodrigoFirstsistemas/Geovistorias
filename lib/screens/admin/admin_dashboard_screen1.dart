import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/organization_list.dart';
import '../../widgets/responsive_layout.dart';

class AdminDashboardScreen extends StatelessWidget {
  final adminController = Get.put(AdminController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Administrativo'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => adminController.loadInitialData(),
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOrganizationDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Criar Nova Organização',
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatCards(),
            SizedBox(height: 16),
            _buildSearchBar(),
            SizedBox(height: 16),
            _buildOrganizationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStatCards(crossAxisCount: 3),
                  SizedBox(height: 16),
                  _buildSearchBar(),
                  SizedBox(height: 16),
                  _buildOrganizationsList(),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildActivityFeed(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStatCards(crossAxisCount: 4),
                  SizedBox(height: 16),
                  _buildSearchBar(),
                  SizedBox(height: 16),
                  _buildOrganizationsList(),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildActivityFeed(),
        ),
      ],
    );
  }

  Widget _buildStatCards({int crossAxisCount = 2}) {
    return Obx(() {
      final stats = adminController.adminStats;
      if (stats.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      return GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          StatCard(
            title: 'Organizações',
            value: '${stats['total_organizations'] ?? 0}',
            subtitle: '${stats['active_organizations'] ?? 0} ativas',
            icon: Icons.business,
            color: Colors.blue,
          ),
          StatCard(
            title: 'Usuários',
            value: '${stats['total_users'] ?? 0}',
            subtitle: '${stats['active_users'] ?? 0} ativos',
            icon: Icons.people,
            color: Colors.green,
          ),
          StatCard(
            title: 'Vistorias',
            value: '${stats['total_inspections'] ?? 0}',
            subtitle: '${stats['completed_inspections'] ?? 0} concluídas',
            icon: Icons.assignment,
            color: Colors.orange,
          ),
          StatCard(
            title: 'Taxa de Conclusão',
            value: stats['total_inspections'] == 0
                ? '0%'
                : '${((stats['completed_inspections'] ?? 0) / stats['total_inspections'] * 100).toStringAsFixed(1)}%',
            subtitle: 'Vistorias concluídas',
            icon: Icons.trending_up,
            color: Colors.purple,
          ),
        ],
      );
    });
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Pesquisar organizações...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: adminController.updateSearchTerm,
    );
  }

  Widget _buildOrganizationsList() {
    return Obx(() {
      if (adminController.isLoading.value &&
          adminController.organizations.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      return OrganizationList(
        organizations: adminController.organizations,
        onEdit: (org) => _showEditOrganizationDialog(Get.context!, org),
        hasMore: adminController.hasMoreItems.value,
        onLoadMore: () => adminController.loadOrganizations(),
      );
    });
  }

  Widget _buildActivityFeed() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Atividades Recentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.notification_important),
                  ),
                  title: Text('Atividade ${index + 1}'),
                  subtitle: Text('Há ${index + 1} horas atrás'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateOrganizationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateOrganizationDialog(),
    );
  }

  void _showEditOrganizationDialog(
      BuildContext context, OrganizationModel organization) {
    showDialog(
      context: context,
      builder: (context) => EditOrganizationDialog(organization: organization),
    );
  }
}
