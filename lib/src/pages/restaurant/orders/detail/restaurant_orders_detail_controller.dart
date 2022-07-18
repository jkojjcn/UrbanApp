import 'package:flutter/material.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/provider/orders_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RestaurantOrdersDetailController {
  late BuildContext context;
  late Function refresh;

  late Product product;

  int counter = 1;
  late double productPrice;

  SharedPref _sharedPref = new SharedPref();

  double total = 0;
  late Order order;
  double time = 10.0;

  late User user;
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
    user = User.fromJson(await _sharedPref.read('user'));
    _usersProvider.init(context, sessionUser: user);
    _ordersProvider.init(context, user);
    getTotal();
    getUsers();
    refresh();
  }

  void sendNotification(String tokenDelivery) {
    Map<String, dynamic> data = {'click_action': 'FLUTTER_NOTIFICATION_CLICK'};

    pushNotificationsProvider.sendMessage(tokenDelivery, data,
        'PEDIDO PENDIENTE', 'Puede haber pedidos pendientes');
  }

  void sendNotificationClient(String tokenDelivery) {
    Map<String, dynamic> data = {'click_action': 'FLUTTER_NOTIFICATION_CLICK'};

    pushNotificationsProvider.sendMessage(tokenDelivery, data,
        'Enciendan las estufas!', 'Estamos preparando tu pedido :D');
  }

  void updateOrder() async {
    try {
      ResponseApi responseApi =
          await _ordersProvider.updateToDispatched(order, time);

      //   User deliveryUser = await _usersProvider.getById(order.idDelivery!);
      users.forEach((element) {
        sendNotification(element.notificationToken ?? "");
      });
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

  void createNotification() async {
    Message mensaje = Message(
        from: int.parse(user.id!),
        to: int.parse(order.client.id!),
        type: 'order',
        message: 'Preparando orden',
        open: 'No');
    try {
      ResponseApi responseApi =
          await _ordersProvider.createNotification(mensaje);

      //  sendNotificationClient(order.client.notificationToken!);
      Fluttertoast.showToast(
          msg: "Notificacion creada", toastLength: Toast.LENGTH_LONG);

      print("Notificacion creada correctamente");
      //  print(deliveryUser.notificationToken);

      Fluttertoast.showToast(
          msg: responseApi.message!, toastLength: Toast.LENGTH_LONG);
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
    order.products.forEach((product) {
      total = total + product.priceRestaurant!;
    });
    refresh();
  }
}
