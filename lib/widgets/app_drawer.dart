import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';

class AppDrawer extends StatelessWidget {
  final _authController = Get.find<AuthController>();

  AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Obx(() {
        final user = _authController.currentUser.value;
        
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(user),
            _buildMainMenuItems(),
            if (_hasAdminAccess(user)) ...[
              const Divider(),
              _buildAdminMenuItems(),
            ],
            const Divider(),
            _buildLogoutItem(),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(User? user) {
    return UserAccountsDrawerHeader(
      accountName: Text(user?.name ?? ''),
      accountEmail: Text(user?.email ?? ''),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          user?.name.substring(0, 1).toUpperCase() ?? '',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildMainMenuItems() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Início'),
          onTap: () => Get.offNamed('/home'),
        ),
        ListTile(
          leading: const Icon(Icons.assignment),
          title: const Text('Vistorias'),
          onTap: () => Get.offNamed('/inspections'),
        ),
        ListTile(
          leading: const Icon(Icons.business),
          title: const Text('Imóveis'),
          onTap: () => Get.offNamed('/properties'),
        ),
        ListTile(
          leading: const Icon(Icons.attach_money),
          title: const Text('Orçamentos'),
          onTap: () => Get.offNamed('/budgets'),
        ),
      ],
    );
  }

  Widget _buildAdminMenuItems() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Administração',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.point_of_sale),
          title: const Text('Terminais'),
          onTap: () => Get.toNamed('/admin/terminals'),
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Usuários'),
          onTap: () => Get.toNamed('/admin/users'),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Configurações'),
          onTap: () => Get.toNamed('/admin/settings'),
        ),
        ListTile(
          leading: const Icon(Icons.analytics),
          title: const Text('Relatórios'),
          onTap: () => Get.toNamed('/admin/reports'),
        ),
      ],
    );
  }

  Widget _buildLogoutItem() {
    return ListTile(
      leading: const Icon(Icons.exit_to_app),
      title: const Text('Sair'),
      onTap: () {
        _authController.logout();
        Get.offAllNamed('/login');
      },
    );
  }

  bool _hasAdminAccess(User? user) {
    if (user == null) return false;
    return user.role == UserRole.admin || user.role == UserRole.manager;
  }
}
