import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './routes/app_routes.dart';
import './services/database_service.dart';
import './services/sync_service.dart';
import './services/notification_service.dart';
import './theme/app_theme.dart';
import './config/env_config.dart';
import 'controllers/auth_controller.dart';
import 'controllers/property_controller.dart';
import 'services/document_template_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carregar configurações do ambiente
  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  // Carregar arquivo .env apropriado
  await dotenv.load(fileName: '.env.$environment');
  
  // Inicializar configurações
  EnvConfig.initialize(_getEnvironment(environment));
  
  // Inicializar timezone para notificações agendadas
  tz.initializeTimeZones();
  
  // Inicializar banco de dados local
  await DatabaseService.init();
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseKey,
  );
  
  // Inicializar serviços do GetX
  await Get.putAsync(() => SyncService().init());
  await Get.putAsync(() => NotificationService().init());
  Get.put(AuthController());
  Get.put(PropertyController());
  Get.put(DocumentTemplateService());

  // Inicializar outros serviços baseados no ambiente
  if (EnvConfig.enableCrashlytics) {
    // TODO: Inicializar Crashlytics
  }
  
  if (EnvConfig.enableAnalytics) {
    // TODO: Inicializar Analytics
  }
  
  if (EnvConfig.enableLogging) {
    // TODO: Configurar logging avançado
  }
  
  runApp(const MyApp());
}

Environment _getEnvironment(String env) {
  switch (env) {
    case 'production':
      return Environment.prod;
    case 'staging':
      return Environment.staging;
    case 'development':
    default:
      return Environment.dev;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sistema Vistorias',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.initial,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.fade,
      debugShowCheckedModeBanner: !EnvConfig.isProduction,
    );
  }
}
