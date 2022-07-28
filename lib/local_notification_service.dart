import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocalNotificationService {
  LocalNotificationService();

  final _localNotificationService = FlutterLocalNotificationsPlugin();

  final BehaviorSubject<String> onNotificationClick = BehaviorSubject();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@drawable/launch_background');

    final InitializationSettings settings =
    InitializationSettings(android: androidInitializationSettings);
    await _localNotificationService.initialize(
      settings,
      onSelectNotification: onSelectNotification,
    );
  }

  Future<NotificationDetails> _notificationDetails() async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('channel_id', 'channel_name',
        channelDescription: 'description',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true);

    return const NotificationDetails(android: androidNotificationDetails);
  }

  Future<void> showNotification({
    int id,
    String title,
    String body,
  }) async {
    final details = await _notificationDetails();
    await _localNotificationService.show(id, title, body, details);
  }

  Future<void> showScheduledNotification(
      {int id, String title, String body, int seconds}) async {
    final details = await _notificationDetails();
    await _localNotificationService.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(DateTime.now().add(Duration(seconds: 10)), tz.local),
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> showPayloadNotification({
    int id,
    String title,
    String body,
    String payload,
  }) async {
    final details = await _notificationDetails();
    await _localNotificationService.show(id, title, body, details, payload: payload);
  }

  void _onDidReceiveLocalNotification(
      int id, String title, String body, String payload) {
    print('id $id');
  }

  void onSelectNotification(String payload) {
    print('payload $payload');
    if(payload != null && payload.isNotEmpty) {
      onNotificationClick.add(payload);
    }
  }
}