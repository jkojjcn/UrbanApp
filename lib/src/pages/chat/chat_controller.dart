import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/provider/message_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatController {
  late BuildContext context;
  SharedPref _sharedPref = new SharedPref();
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  late Function refresh;
  User? user;
  List<Message> message = [];
  late List<Message> unreadMessages = [];

  TextEditingController messageController = new TextEditingController();

  List<String> messageList = [];

  List<Message> messageListModel = [];

  Timer? searchOnStoppedTyping;

  double distanciaCliente = 0.0;

  List<Product>? selectedProducts = [];

  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();

  MessageProvider messageProvider = new MessageProvider();
  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));

    selectedProducts =
        Product.fromJsonList(await _sharedPref.read('order')).toList;
    await messageProvider.init(context, user!);

    refresh();
    getMessages();
  }

  Future<List<Message>> unreadMessage() async {
    message.forEach((element) {
      if (element.open != "Si") {
        if (!unreadMessages.contains(element)) {
          unreadMessages.add(element);
        }
      }
    });
    unreadMessages.toSet();
    return unreadMessages;
  }

  Future<List<Message>> getMessages() async {
    try {
      message = await messageProvider.getMessage(user!.id!);
      print(message.length);
      return message;
    } on Exception catch (e) {
      print(e);
      return [];
    }
  }

  void launchURL(url) async {
    // ignore: deprecated_member_use
    if (!await launch(url)) throw 'Could not launch $url';
  }
}
