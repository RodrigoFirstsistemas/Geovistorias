import 'package:get/get.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/test_connection_screen.dart';
import '../middleware/auth_middleware.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/login',
      page: () => LoginScreen(),
    ),
    GetPage(
      name: '/home',
      page: () => HomeScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/test-connection',
      page: () => TestConnectionScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
