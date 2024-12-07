import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_pages.dart';

class AdminLayout extends StatelessWidget {
  final String selectedRoute;
  final Widget child;

  const AdminLayout({
    Key? key,
    required this.selectedRoute,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Sistema Vistorias - Painel Administrativo'),
        actions: [
          _buildUserMenu(),
        ],
      ),
      sideBar: _buildSideBar(context),
      body: child,
    );
  }

  Widget _buildUserMenu() {
    final authController = Get.find<AuthController>();
    
    return Obx(() {
      final user = authController.currentUser.value;
      if (user == null) return const SizedBox.shrink();

      return PopupMenuButton(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Text(user.name[0].toUpperCase()),
              ),
              const SizedBox(width: 8),
              Text(user.name),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () => Get.toNamed(Routes.PROFILE),
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () => Get.toNamed(Routes.SETTINGS),
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () => authController.logout(),
            ),
          ),
        ],
      );
    });
  }

  SideBar _buildSideBar(BuildContext context) {
    return SideBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      activeBackgroundColor: Theme.of(context).colorScheme.primary,
      activeTextStyle: const TextStyle(color: Colors.white),
      textStyle: const TextStyle(color: Colors.black54),
      items: [
        AdminMenuItem(
          title: 'Dashboard',
          icon: Icons.dashboard,
          route: Routes.DASHBOARD,
        ),
        AdminMenuItem(
          title: 'Terminais',
          icon: Icons.point_of_sale,
          route: Routes.TERMINALS,
        ),
        AdminMenuItem(
          title: 'Usuários',
          icon: Icons.people,
          route: Routes.USERS,
        ),
        const AdminMenuItem(
          title: 'Relatórios',
          icon: Icons.analytics,
          children: [
            AdminMenuItem(
              title: 'Vistorias',
              route: Routes.REPORTS_INSPECTIONS,
            ),
            AdminMenuItem(
              title: 'Orçamentos',
              route: Routes.REPORTS_BUDGETS,
            ),
            AdminMenuItem(
              title: 'Pagamentos',
              route: Routes.REPORTS_PAYMENTS,
            ),
          ],
        ),
        AdminMenuItem(
          title: 'Configurações',
          icon: Icons.settings,
          route: Routes.SETTINGS,
        ),
      ],
      selectedRoute: selectedRoute,
      onSelected: (item) {
        if (item.route != null) {
          Get.toNamed(item.route!);
        }
      },
    );
  }
}
