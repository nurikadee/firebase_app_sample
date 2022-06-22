import 'package:firebase_app_sample/models/message.arguments.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MessagingHelper {
  static goToInboxScreen(context, RemoteMessage? remoteMessage) {
    if (remoteMessage != null) {
      Navigator.pushNamed(context, '/message',
          arguments: MessageArguments(remoteMessage, true));
    }
  }
}
