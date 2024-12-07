import 'package:get/get.dart';
import '../screens/dashboard_screen.dart';
import '../screens/property_list_screen.dart';
import '../screens/property_detail_screen.dart';
import '../screens/inspection_list_screen.dart';
import '../screens/inspection_detail_screen.dart';
import '../screens/client_list_screen.dart';
import '../screens/client_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/terminal_management_screen.dart';
import '../middleware/admin_middleware.dart';

class AppRoutes {
  static const initial = '/login';
  static const dashboard = '/dashboard';
  static const properties = '/properties';
  static const propertyDetail = '/property/:id';
  static const inspections = '/inspections';
  static const inspectionDetail = '/inspection/:id';
  static const clients = '/clients';
  static const clientDetail = '/client/:id';
  static const settings = '/settings';
  static const adminDashboard = '/admin';
  static const adminTerminals = '/admin/terminals';

  static final routes = [
    GetPage(
      name: initial,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: dashboard,
      page: () => DashboardScreen(),
    ),
    GetPage(
      name: properties,
      page: () => PropertyListScreen(),
    ),
    GetPage(
      name: propertyDetail,
      page: () => PropertyDetailScreen(),
    ),
    GetPage(
      name: inspections,
      page: () => InspectionListScreen(),
    ),
    GetPage(
      name: inspectionDetail,
      page: () => InspectionDetailScreen(),
    ),
    GetPage(
      name: clients,
      page: () => ClientListScreen(),
    ),
    GetPage(
      name: clientDetail,
      page: () => ClientDetailScreen(),
    ),
    GetPage(
      name: settings,
      page: () => SettingsScreen(),
    ),
    GetPage(
      name: adminDashboard,
      page: () => AdminDashboardScreen(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: adminTerminals,
      page: () => TerminalManagementScreen(),
      middlewares: [AdminMiddleware()],
    ),
  ];
}
