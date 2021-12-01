import 'dart:io';

import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:saiive.live/push/push_notification_model.dart';
import 'package:saiive.live/push/push_notification_received_event.dart';

abstract class IPushService {
  Future registerPushService();
  Future checkForInitialMessage();

  Future<String> getNotificationToken();
}

class PushService implements IPushService {
  FirebaseMessaging _messaging;

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  @override
  Future registerPushService() async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return;
    }
    await Firebase.initializeApp();

    _messaging = FirebaseMessaging.instance;

    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      var notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );
      EventTaxiImpl.singleton().fire(PushNotificationReceivedEvent(notification));
    });

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');

        // Parse the message received
        var notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );

        if (notification != null) {
          EventTaxiImpl.singleton().fire(PushNotificationReceivedEvent(notification));
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future checkForInitialMessage() async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return;
    }
    await Firebase.initializeApp();
    var initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );
      EventTaxiImpl.singleton().fire(PushNotificationReceivedEvent(notification));
    }
  }

  @override
  Future<String> getNotificationToken() {
    return FirebaseMessaging.instance.getToken();
  }
}
