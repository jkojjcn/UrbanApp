import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/delivery/orders/map/delivery_orders_map_page.dart';
import 'package:jcn_delivery/src/provider/orders_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DeliveryOrdersDetailController {
  late BuildContext context;
  late Function refresh;

  Product? product;

  int counter = 1;
  double? productPrice;

  SharedPref _sharedPref = new SharedPref();

  double total = 0;
  double totalCliente = 0;
  Order? order;

  User? user;
  List<User> users = [];
  UsersProvider _usersProvider = new UsersProvider();
  MoneyMaskedTextController priceController = new MoneyMaskedTextController();
  OrdersProvider _ordersProvider = new OrdersProvider();
  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();
  String? idDelivery;

  Future init(BuildContext context, Function refresh, Order order) async {
    this.context = context;
    this.refresh = refresh;
    this.order = order;
    user = User.fromJson(await _sharedPref.read('user'));
    _usersProvider.init(context, sessionUser: user);
    _ordersProvider.init(context, user!);
    getTotal();
    getTotalCliente();
    getUsers();
    refresh();
  }

  void updateOrder(double totalDelivery) async {
    if (order?.status == 'DESPACHADO') {
      ResponseApi responseApi =
          await _ordersProvider.updateToOnTheWay(order!, totalDelivery);
      Fluttertoast.showToast(
          msg: responseApi.message!, toastLength: Toast.LENGTH_LONG);
      if (responseApi.success!) {
        Fluttertoast.showToast(msg: 'Vé con cuidado');
        Navigator.pop(context);
        /*  Navigator.pushNamed(context, 'delivery/orders/map',
            arguments: order?.toJson());*/
      }
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DeliveryOrdersMapPage(order: order)));
    }
  }

  void sendNotificationClient(String tokenDelivery) {
    Map<String, dynamic> data = {'click_action': 'FLUTTER_NOTIFICATION_CLICK'};

    pushNotificationsProvider.sendMessage(
        tokenDelivery,
        data,
        'Enciendan las estufas!',
        'Hola, soy ${user?.name} " me encuentro en camino.."');
  }

  void createNotification() async {
    Message mensaje = Message(
        from: int.parse(user?.id ?? "0"),
        to: int.parse(order?.client.id ?? '0'),
        type: 'order',
        message: 'Orden en camino',
        open: 'No');
    try {
      ResponseApi responseApi =
          await _ordersProvider.createNotification(mensaje);

      sendNotificationClient(order?.client.notificationToken ?? "");
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
    order?.products.forEach((product) {
      total = total + (product.priceRestaurant! * product.quantity!);
    });
    refresh();
  }

  void getTotalCliente() {
    totalCliente = 0;
    order?.products.forEach((product) {
      totalCliente = totalCliente + (product.price! * product.quantity!);
    });
    refresh();
  }
}
