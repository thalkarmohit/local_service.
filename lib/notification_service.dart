import 'dart:ui' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);

    // Request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showBookingConfirmation({
    required String providerName,
    required String service,
    required String date,
    required String time,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'booking_channel',
      'Booking Notifications',
      channelDescription: 'Notifications for booking confirmations',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF1565C0),
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '✅ Booking Confirmed!',
      '$providerName ($service) booked for $date at $time',
      details,
    );
  }

  Future<void> showReminderNotification({
    required String providerName,
    required String service,
    required String time,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Booking Reminders',
      channelDescription: 'Reminders for upcoming bookings',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF1565C0),
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🔔 Upcoming Booking',
      '$service with $providerName today at $time',
      details,
    );
  }
}