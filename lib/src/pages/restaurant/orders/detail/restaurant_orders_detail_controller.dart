import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/chat.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/provider/chats_provider.dart';
import 'package:jcn_delivery/src/provider/orders_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RestaurantOrdersDetailController {
  late BuildContext context;
  late Function refresh;

  late Product product;

  User user = User.fromJson(GetStorage().read('user'));

  ChatProvider chatProvider = Get.put(ChatProvider());
  GeneralActions generalActions = Get.put(GeneralActions());

  int counter = 1;
  late double productPrice;

  double total = 0;
  late Order order;
  double time = 10.0;

  List<User> users = [];
  UsersProvider _usersProvider = new UsersProvider();
  OrdersProvider _ordersProvider = new OrdersProvider();

  List<Product> productsAvariable = [];

  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();
  late String idDelivery;

  Future init(BuildContext context, Function refresh, Order order) async {
    this.context = context;
    this.refresh = refresh;
    this.order = order;

    _usersProvider.init(context, sessionUser: user);
    _ordersProvider.init(context, user);
    getTotal();
    getUsers();
    refresh();
  }

  void createChat(User userReceiver) async {
    Chat chat = Chat(idUser1: user.id, idUser2: userReceiver.id);

    bool exist = generalActions.chats.any((element) =>
        (element.idUser1 == user.id && element.idUser2 == userReceiver.id) &&
        (element.idUser1 == userReceiver.id && element.idUser2 == user.id));
    log(exist.toString());

    if (exist == false) {
      ResponseApi responseApi = await chatProvider.create(chat);

      if (responseApi.success == true) {
        Get.toNamed('/messages', arguments: {'user': userReceiver.toJson()});
        //  Get.snackbar('Creado', responseApi.message ?? 'Error en la respuesta');
      }
    } else {
      log('Chat encontrado');
      Get.toNamed('/messages', arguments: {'user': userReceiver.toJson()});
    }

    log(exist.toString());
  }

  void sendNotification(String tokenDelivery) {
    Map<String, dynamic> data = {'click_action': 'FLUTTER_NOTIFICATION_CLICK'};

    pushNotificationsProvider.sendMessage(tokenDelivery, data,
        'PEDIDO PENDIENTE', 'Puede haber pedidos pendientes');
  }

  void sendNotificationClient(String tokenDelivery) {
    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'title': 'Preparando orden',
      'body': 'El restaurante está preparando su orden',
      'id_message': 'idMensaje',
      'id_chat': 'idChat',
      'url': 'restaurant'
    };

    pushNotificationsProvider.sendMessage(tokenDelivery, data,
        'Enciendan las estufas!', 'Estamos preparando tu pedido :D');
  }

  void updateOrder() async {
    try {
      ResponseApi responseApi =
          await _ordersProvider.updateToDispatched(order, time);

      if (user.lastname!.contains('04')) {
        users.forEach((element) {
          if (element.lastname!.contains('04')) {
            Map<String, dynamic> data = {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'title': 'Orden disponible',
              'body': 'Se ha generado una orden! :D',
              'id_message': 'idMensaje',
              'id_chat': 'idChat',
              'url': 'specific'
            };
            pushNotificationsProvider.sendOrders(element.notificationToken!,
                data, 'Orden disponible', 'Se ha generado una orden! :D');
          }
        });
      } else if (user.lastname!.contains('07')) {
        users.forEach((element) {
          if (element.lastname!.contains('07')) {
            Map<String, dynamic> data = {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'title': 'Orden disponible',
              'body': 'Se ha generado una orden! :D',
              'id_message': 'idMensaje',
              'id_chat': 'idChat',
              'url': 'specific'
            };
            pushNotificationsProvider.sendOrders(element.notificationToken!,
                data, 'Orden disponible', 'Se ha generado una orden! :D');
          }
        });
      }

      sendNotificationClient(order.client.notificationToken!);

      Fluttertoast.showToast(
          msg: "Tiempo de preparación establecido",
          toastLength: Toast.LENGTH_LONG);

      //  print(deliveryUser.notificationToken);

      Fluttertoast.showToast(
          msg: responseApi.message!, toastLength: Toast.LENGTH_LONG);
      Navigator.pop(context, true);
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: 'Intentalo nuevamente');
    }
  }

  void getUsers() async {
    users = await _usersProvider.getDeliveryMen();
    refresh();
  }

  void getTotal() {
    total = 0;
    order.productsOrder!.forEach((productsOrder) {
      total = total + productsOrder.priceRestaurant!;
    });
    refresh();
  }
}
