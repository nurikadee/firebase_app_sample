import 'package:firebase_messaging/firebase_messaging.dart';

class MessageArguments {
  final RemoteMessage message;

  final bool openedApplication;

  MessageArguments(this.message, this.openedApplication);
}
