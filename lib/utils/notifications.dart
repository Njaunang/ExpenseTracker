import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications extends StatelessWidget {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notifications.initialize(settings: initializationSettings);
  }

  static Future<void> showSpendingAlert(double overSpend) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'spending_alerts',
          'Spending Alerts',
          channelDescription: 'Notifications for overspending',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentSound: true,
      presentBadge: true,
      presentAlert: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(
      id: 0,
      title: 'Spending Alert',
      body:
          'You have exceeded your budget by \$${overSpend.toStringAsFixed(2)} this month.',
      notificationDetails: platformDetails,
    );
  }

  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class Notifications {
//   static final FlutterLocalNotificationsPlugin _notifications =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings();

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//           android: initializationSettingsAndroid,
//           iOS: initializationSettingsIOS,
//         );

//     await _notifications.initialize(settings: initializationSettings);
//   }

//   static Future<void> showSpendingAlert(double overspend) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//           'spending_alerts',
//           'Spending Alerts',
//           channelDescription: 'Notifications for spending alerts',
//           importance: Importance.high,
//           priority: Priority.high,
//         );

//     const DarwinNotificationDetails iOSPlatformChannelSpecifics =
//         DarwinNotificationDetails();

//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics,
//     );

//     await _notifications.show(
//       id: 0,
//       title: 'Spending Alert!',
//       body:
//           'You have exceeded your income by \$${overspend.toStringAsFixed(2)} this month!',
//       notificationDetails: platformChannelSpecifics,
//     );
//   }
// }
