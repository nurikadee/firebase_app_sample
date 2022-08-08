import 'package:firebase_app_sample/helper/messaging.helper.dart';
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
  String? messageStatus;

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  Future<void> setupInteractedMessage() async {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? initialMessage) {
      if (initialMessage != null) {
        setState(() {
          if (initialMessage.notification != null) {
            messageStatus = '[getInitialMessage]'
                '\n${initialMessage.notification?.title}';
          }
        });
        _handleMessage(initialMessage);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      RemoteNotification? notification = remoteMessage.notification;
      AndroidNotification? android = remoteMessage.notification?.android;

      AndroidInitializationSettings androidInitSettings =
          const AndroidInitializationSettings('mipmap/ic_launcher');
      IOSInitializationSettings iosInitSettings =
          const IOSInitializationSettings();
      var platform = InitializationSettings(
          android: androidInitSettings, iOS: iosInitSettings);

      flutterLocalNotificationsPlugin.initialize(
        platform,
        onSelectNotification: (payload) async {
          setState(() {
            if (remoteMessage.notification != null) {
              messageStatus = '[onMessage Click]'
                  '\n${remoteMessage.notification?.title}';
            }
          });

          _handleMessage(remoteMessage);
        },
      );

      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: 'mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      debugPrint('onMessageOpenedApp');
      setState(() {
        if (remoteMessage.notification != null) {
          messageStatus = '[onMessageOpenedApp]'
              '\n${remoteMessage.notification?.title}';
        }
      });
      _handleMessage(remoteMessage);
    });
  }

  void _handleMessage(RemoteMessage message) {
    MessagingHelper.goToInboxScreen(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Cloud Messaging'),
      ),
      body: Center(
        child: Text('Messaging Status : ${messageStatus ?? 'N/A'}'),
      ),
    );
  }
}
