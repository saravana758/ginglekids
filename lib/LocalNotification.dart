import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationApp {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int _notificationId = 0;
  Timer? _timer;

  void initNotifications() async {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void scheduleDailyNotification() async {
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Indian time zone
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      10, // Hour
      13, // Minute
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    await flutterLocalNotificationsPlugin.zonedSchedule(
      _notificationId++,
      'Notification Title',
      'This is a notification message',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'Channel Name',
          channelDescription: 'Channel Description',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void startCurrentTimeUpdater() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      final now = tz.TZDateTime.now(tz.local);
      // Check if the current time is 10:25:00 AM
      if (now.hour == 12 && now.minute == 50 && now.second == 0) {
        _showImmediateNotification();
      }
    });
  }

  Future<void> _showImmediateNotification() async {
    const androidNotificationDetails = AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      channelDescription: 'Channel Description',
      importance: Importance.high,
      priority: Priority.high,
    );
    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      'Immediate Notification',
      'This is an immediate notification triggered at 10:25 AM',
      const NotificationDetails(
        android: androidNotificationDetails,
      ),
    );
  }

  void dispose() {
    _timer?.cancel();
  }
}
