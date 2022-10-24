import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/chat.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/delivery/orders/map/delivery_orders_map_page.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/chat_controller.dart';
import 'package:jcn_delivery/src/provider/chats_provider.dart';
import 'package:jcn_delivery/src/provider/orders_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';

class DeliveryOrdersDetailController {
  late BuildContext context;
  late Function refresh;

  Product? product;

  Order? order;

  List<User> users = [];
  UsersProvider _usersProvider = new UsersProvider();
  MoneyMaskedTextController priceController = new MoneyMaskedTextController();
  OrdersProvider _ordersProvider = new OrdersProvider();
  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();

  User user = User.fromJson(GetStorage().read('user'));

  ChatProvider chatProvider = Get.put(ChatProvider());
  GeneralActions generalActions = Get.put(GeneralActions());
  ChatMainController chatController = Get.put(ChatMainController());

  Future init(BuildContext context, Function refresh, Order order) async {
    this.context = context;
    this.refresh = refresh;
    this.order = order;
    _usersProvider.init(context, sessionUser: user);
    _ordersProvider.init(context, user);
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

  void updateOrder(double totalDelivery) async {
    if (order?.status == 'DESPACHADO') {
      ResponseApi responseApi =
          await _ordersProvider.updateToOnTheWay(order!, totalDelivery);
      Fluttertoast.showToast(
          msg: responseApi.message!, toastLength: Toast.LENGTH_LONG);
      if (responseApi.success!) {
        Fluttertoast.showToast(msg: 'Vé con cuidado');

        Navigator.pop(context);
      }
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DeliveryOrdersMapPage(order: order)));
    }
  }

  void sendNotificationClient(String tokenDelivery) {
    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'title': 'Hola soy ${user.name} de Rush!',
      'body': 'Me encuentro en camino :D',
      'id_message': 'idMensaje',
      'id_chat': 'idChat',
      'url': 'global'
    };

    pushNotificationsProvider.sendMessage(tokenDelivery, data,
        'Hola soy ${user.name} de Rush!', 'Me encuentro en camino :D');
  }

  double restaurantDistanceDelivery(Order order) {
    double totalOrder = 0.0;
    order.productsOrder!.forEach((element) {
      totalOrder = totalOrder + element.priceRestaurant!;
    });
    return totalOrder;
  }

  void getUsers() async {
    users = await _usersProvider.getDeliveryMen();
    refresh();
  }
}
