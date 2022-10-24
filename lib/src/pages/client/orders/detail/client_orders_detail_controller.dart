import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/chat.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/client/orders/map/client_orders_map_page.dart';
import 'package:jcn_delivery/src/provider/chats_provider.dart';
import 'package:jcn_delivery/src/provider/orders_provider.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';

class ClientOrdersDetailController {
  late BuildContext context;
  late Function refresh;

  Product? product;

  int counter = 1;
  double? productPrice;

  double total = 0;
  late Order order;
  double? distanciaDelivery;

  User user = User.fromJson(GetStorage().read('user'));
  List<User> users = [];
  UsersProvider _usersProvider = new UsersProvider();
  OrdersProvider _ordersProvider = new OrdersProvider();

  GeneralActions generalActions = Get.put(GeneralActions());
  ChatProvider chatProvider = Get.put(ChatProvider());
  String? idDelivery;

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

    if (exist == false) {
      ResponseApi responseApi = await chatProvider.create(chat);

      if (responseApi.success == true) {
        Get.toNamed('/messages', arguments: {'user': userReceiver.toJson()});
        //  Get.snackbar('Creado', responseApi.message ?? 'Error en la respuesta');
      }
    } else {
      Get.toNamed('/messages', arguments: {'user': userReceiver.toJson()});
    }
  }

  void updateOrder() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClientOrdersMapPage(order: order)));
  }

  void getUsers() async {
    users = await _usersProvider.getDeliveryMen();
    refresh();
  }

  void getTotal() {
    total = 0;
    order.productsOrder?.forEach((productsOrder) {
      total = (total + productsOrder.price!) - 0.10;
    });
    total = total + restaurantDistance(order.distance);
    refresh();
  }

  restaurantDistance(_distanceRC) {
    if (_distanceRC / 1000 <= 1) {
      distanciaDelivery = 0.99;
    } else if (_distanceRC / 1000 <= 2) {
      distanciaDelivery = 0.99;
    } else if ((_distanceRC / 1000 > 2) && (_distanceRC / 1000 <= 3)) {
      distanciaDelivery = 1.49;
    } else if ((_distanceRC / 1000 > 3) && (_distanceRC / 1000 <= 4)) {
      distanciaDelivery = 1.99;
    } else if ((_distanceRC / 1000 > 4) && (_distanceRC / 1000 <= 5)) {
      distanciaDelivery = 2.49;
    } else if ((_distanceRC / 1000 > 5) && (_distanceRC / 1000 <= 6)) {
      distanciaDelivery = 3.25;
    } else if ((_distanceRC / 1000 > 6) && (_distanceRC / 1000 <= 7)) {
      distanciaDelivery = 3.69;
    } else if ((_distanceRC / 1000 > 7) && (_distanceRC / 1000 <= 8)) {
      distanciaDelivery = 4.10;
    } else if ((_distanceRC / 1000 > 8) && (_distanceRC / 1000 <= 9)) {
      distanciaDelivery = 4.49;
    } else if ((_distanceRC / 1000 > 9) && (_distanceRC / 1000 <= 10)) {
      distanciaDelivery = 4.99;
    } else if ((_distanceRC / 1000 > 10) && (_distanceRC / 1000 <= 11)) {
      distanciaDelivery = 5.25;
    } else if ((_distanceRC / 1000 > 11) && (_distanceRC / 1000 <= 12)) {
      distanciaDelivery = 5.99;
    } else if ((_distanceRC / 1000 > 12 && (_distanceRC / 1000 <= 13))) {
      distanciaDelivery = 6.25;
    } else {
      return Icon(Icons.credit_card);
    }
    return distanciaDelivery;
  }
}
