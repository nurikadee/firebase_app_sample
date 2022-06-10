import 'dart:developer';

import 'package:firebase_app_sample/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RemoteMessage? message;
  RemoteNotification? notification;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        setState(() {
          message = remoteMessage;
        });
      }
    });

    FirebaseMessaging.instance
        .getToken()
        .then((token) => log('FCM Token : $token'));

    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      RemoteNotification? notification = remoteMessage.notification;
      AndroidNotification? android = remoteMessage.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              icon: 'mipmap/ic_launcher',
            ),
          ),
        );
      }

      setState(() {
        message = remoteMessage;
        notification = remoteMessage.notification;
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      log('A new onMessageOpenedApp event was published!');
      setState(() {
        message = remoteMessage;
      });
    });
  }

  Widget row(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: '),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Cloud Messaging'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              row('Message ID', message?.messageId),
              row('Sender ID', message?.senderId),
              row('Category', message?.category),
              row('Collapse Key', message?.collapseKey),
              row('Content Available', message?.contentAvailable.toString()),
              row('Data', message?.data.toString()),
              row('From', message?.from),
              row('Message ID', message?.messageId),
              row('Sent Time', message?.sentTime?.toString()),
              row('Thread ID', message?.threadId),
              row('Time to Live (TTL)', message?.ttl?.toString()),
              if (notification != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Remote Notification',
                          style: TextStyle(fontSize: 18)),
                      row('Title', notification?.title),
                      row('Body', notification?.body),
                      if (notification?.android != null) ...[
                        const SizedBox(height: 16),
                        const Text('Android Properties',
                            style: TextStyle(fontSize: 18)),
                        row('Channel ID', notification?.android!.channelId),
                        row('Click Action', notification?.android!.clickAction),
                        row('Color', notification?.android!.color),
                        row('Count', notification?.android!.count?.toString()),
                        row('Image URL', notification?.android!.imageUrl),
                        row('Link', notification?.android!.link),
                        row('Priority',
                            notification?.android!.priority.toString()),
                        row('Small Icon', notification?.android!.smallIcon),
                        row('Sound', notification?.android!.sound),
                        row('Ticker', notification?.android!.ticker),
                        row('Visibility',
                            notification?.android!.visibility.toString()),
                      ],
                      if (notification?.apple != null) ...[
                        const Text('Apple Properties',
                            style: TextStyle(fontSize: 18)),
                        row('Subtitle', notification?.apple!.subtitle),
                        row('Badge', notification?.apple!.badge),
                        row('Sound', notification?.apple!.sound?.name),
                      ]
                    ],
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
