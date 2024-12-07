import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService extends GetxService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // TODO: Implementar navegação baseada no payload
    if (response.payload != null) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        Map.from(response.payload as Map),
      );
      
      if (data['route'] != null) {
        Get.toNamed(data['route']);
      }
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'sistema_vistorias',
      'Sistema Vistorias',
      channelDescription: 'Notificações do Sistema de Vistorias',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'sistema_vistorias_scheduled',
      'Sistema Vistorias Agendadas',
      channelDescription: 'Notificações agendadas do Sistema de Vistorias',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Notificações específicas do sistema
  Future<void> showSyncCompleteNotification() async {
    await showNotification(
      title: 'Sincronização Concluída',
      body: 'Todos os dados foram sincronizados com sucesso!',
    );
  }

  Future<void> showSyncErrorNotification(String error) async {
    await showNotification(
      title: 'Erro na Sincronização',
      body: 'Ocorreu um erro ao sincronizar: $error',
    );
  }

  Future<void> showBackupCompleteNotification() async {
    await showNotification(
      title: 'Backup Concluído',
      body: 'Backup realizado com sucesso!',
    );
  }

  Future<void> showInspectionReminderNotification(
    String propertyName,
    DateTime scheduledDate,
  ) async {
    await scheduleNotification(
      title: 'Lembrete de Vistoria',
      body: 'Você tem uma vistoria agendada para $propertyName',
      scheduledDate: scheduledDate.subtract(const Duration(hours: 1)),
      payload: '{"route": "/inspections"}',
    );
  }

  Future<void> showNewPropertyNotification(String propertyName) async {
    await showNotification(
      title: 'Novo Imóvel',
      body: 'O imóvel $propertyName foi adicionado ao sistema',
      payload: '{"route": "/properties"}',
    );
  }

  Future<void> showNewInspectionNotification(
    String propertyName,
    String inspectionId,
  ) async {
    await showNotification(
      title: 'Nova Vistoria',
      body: 'Uma nova vistoria foi criada para $propertyName',
      payload: '{"route": "/inspection/$inspectionId"}',
    );
  }

  Future<void> showNewClientNotification(String clientName) async {
    await showNotification(
      title: 'Novo Cliente',
      body: 'O cliente $clientName foi adicionado ao sistema',
      payload: '{"route": "/clients"}',
    );
  }
}
