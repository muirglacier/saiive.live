import 'package:event_taxi/event_taxi.dart';
import 'package:saiive.live/push/push_notification_model.dart';

class PushNotificationReceivedEvent extends Event {
  final PushNotification notification;

  PushNotificationReceivedEvent(this.notification);
}
