import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    // Se não estiver logado, redireciona para login
    if (user == null && route != '/login' && route != '/register') {
      return const RouteSettings(name: '/login');
    }

    // Se estiver logado mas for rota de login/registro, vai para home
    if (user != null && (route == '/login' || route == '/register')) {
      return const RouteSettings(name: '/home');
    }

    // Verifica permissões de admin
    if (_isAdminRoute(route) && !_hasAdminAccess(user)) {
      return const RouteSettings(name: '/home');
    }

    return null;
  }

  bool _isAdminRoute(String? route) {
    final adminRoutes = [
      '/admin',
      '/admin/terminals',
      '/admin/users',
      '/admin/settings',
    ];
    return route != null && adminRoutes.any((r) => route.startsWith(r));
  }

  bool _hasAdminAccess(User? user) {
    if (user == null) return false;
    return user.role == UserRole.admin || user.role == UserRole.manager;
  }
}
