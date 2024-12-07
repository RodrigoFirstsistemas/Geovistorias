import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    // Verifica se o usuário está logado e é admin
    if (!authController.isLoggedIn || !authController.currentUser.value?.isAdmin ?? true) {
      return RouteSettings(name: '/login');
    }
    
    return null;
  }
}
