import 'dart:convert';
import 'dart:core';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class PushNotificationsProvider extends GetConnect {
  AndroidNotificationChannel globalchannel = AndroidNotificationChannel(
      'global_channel', 'Notificaciones Globales',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('general'),
      importance: Importance.high);

  AndroidNotificationChannel specificchannel = AndroidNotificationChannel(
      'specific_channel', 'Notificaciones Importantes',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('partner'));
  FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  void initPushNotifications() async {
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(globalchannel);
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(specificchannel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void onMessageListener() async {
    FirebaseMessaging.instance.getInitialMessage();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });
  }

  void saveToken(String idUser) async {
    String? token = await FirebaseMessaging.instance.getToken();
    UsersProvider usersProvider = UsersProvider();
    if (token != null) {
      await usersProvider.updateNotificationToken(idUser, token);
    }
  }

  void showNotification(RemoteMessage message) async {
    AndroidNotificationDetails? androidPlatformChannelSpecifics;

    if (message.data['url'] == 'global') {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
          globalchannel.id, globalchannel.name,
          playSound: true, icon: 'mipmap/logofly');
    } else if (message.data['url'] == 'specific') {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        specificchannel.id,
        specificchannel.name,
        icon: 'mipmap/logofly',
        playSound: true,
      );
    } else {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        globalchannel.id,
        globalchannel.name,
        icon: 'mipmap/logofly',
        playSound: false,
      );
    }

    plugin.show(1, message.data['title'], message.data['body'],
        NotificationDetails(android: androidPlatformChannelSpecifics));
  }

  Future<void> sendMessage(
      String to, Map<String, dynamic> data, String title, String body) async {
    Uri url = Uri.https('fcm.googleapis.com', '/fcm/send');
    print('mandando mensaje');

    await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAsL4c97c:APA91bHhEqCMi5t4LvD24Vlh0qIvSXiMqL4u7m8d8gKM89-JsjjoApjixu6eVAiPEZjlguHSacVMH87a2bgSKBhFf7WmBRwKtSD7Vb3wLvgzvwjBVIkjsOQNPfZLoQ5s3J7clghxlEHL'
        },
        body: jsonEncode(<String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'notification': <String, dynamic>{
            'android_channel_id': 'global_channel',
            'body': body,
            'title': title
          },
          'priority': 'high',
          'ttl': '4500s',
          'data': data,
          'to': to
        }));
  }

  Future<void> sendOrders(
      String to, Map<String, dynamic> data, String title, String body) async {
    Uri url = Uri.https('fcm.googleapis.com', '/fcm/send');
    print('mandando mensaje');

    await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAsL4c97c:APA91bHhEqCMi5t4LvD24Vlh0qIvSXiMqL4u7m8d8gKM89-JsjjoApjixu6eVAiPEZjlguHSacVMH87a2bgSKBhFf7WmBRwKtSD7Vb3wLvgzvwjBVIkjsOQNPfZLoQ5s3J7clghxlEHL'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'android_channel_id': 'specific_channel',
            'body': body,
            'title': title,
            'sound': 'partner.wav'
          },
          'priority': 'high',
          'ttl': '4500s',
          'data': data,
          'to': to
        }));
  }

  Future<void> sendMessageMultiple(List<String> toList,
      Map<String, dynamic> data, String title, String body) async {
    Uri url = Uri.https('fcm.googleapis.com', '/fcm/send');

    await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAsL4c97c:APA91bHhEqCMi5t4LvD24Vlh0qIvSXiMqL4u7m8d8gKM89-JsjjoApjixu6eVAiPEZjlguHSacVMH87a2bgSKBhFf7WmBRwKtSD7Vb3wLvgzvwjBVIkjsOQNPfZLoQ5s3J7clghxlEHL'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title,
          },
          'priority': 'high',
          'ttl': '4500s',
          'data': data,
          'registration_ids': toList
        }));
  }
}
