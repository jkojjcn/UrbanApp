import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/chat.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/restaurant.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/chat_controller.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/chats/chats_controller.dart';
import 'package:jcn_delivery/src/pages/restaurant/orders/detail/restaurant_orders_detail_page.dart';
import 'package:jcn_delivery/src/provider/chats_provider.dart';
import 'package:jcn_delivery/src/provider/orders_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/provider/restaurants_provider.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class RestaurantOrdersListController {
  late BuildContext context;
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  late Function refresh;
  User user = User.fromJson(GetStorage().read('user'));
  ChatMainController chatController = Get.put(ChatMainController());
  ChatProvider chatProvider = ChatProvider();
  ChatsController chatsControllers = Get.put(ChatsController());
  GeneralActions generalActions = Get.put(GeneralActions());

  List<String> status = ['PAGADO', 'DESPACHADO', 'EN CAMINO', 'ENTREGADO'];
  OrdersProvider _ordersProvider = new OrdersProvider();
  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();

  RestaurantsProvider _restaurantsProvider = new RestaurantsProvider();

  late bool isUpdated;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    chatsControllers.listenMessage();
    _ordersProvider.init(context, user);
    refresh();
  }

  Future<List<Order>> getOrders(String status) async {
    return await _ordersProvider.getByStatus(status);
  }

  Future<List<Order>> getOrdersByRestaurant(
      String status, String restaurantId) async {
    return await _ordersProvider.getByRestaurantId(status, restaurantId);
  }

  Future<List<Restaurant>> getProducts(
      String idCategory, String productName) async {
    if (productName.isEmpty) {
      return await _restaurantsProvider.getByCategory(user.id!);
    } else {
      return await _restaurantsProvider.getByCategoryAndRestaurantName(
          '4', '${user.name}');
    }
  }

  void openBottomSheet(Order order) async {
    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => RestaurantOrdersDetailPage(order: order));
  }

  void sendNotification(String tokenDelivery) {
    Map<String, dynamic> data = {'click_action': 'FLUTTER_NOTIFICATION_CLICK'};

    pushNotificationsProvider.sendMessage(
        tokenDelivery, data, 'PEDIDO ASIGNADO', 'te han asignado un pedido');
  }

  void logout() async {
    GetStorage().remove('user');
    Get.offNamedUntil('/login', (route) => false);
  }

  void goToCategoryCreate() {
    Get.toNamed('/restaurant/categories/create');
  }

  void goToProductCreate() {
    Get.toNamed('/restaurant/products/create');
  }

  void openDrawer() {
    key.currentState?.openDrawer();
  }

  void goToRoles() {
    Get.offNamedUntil('/roles', (route) => false);
  }

  void goToChat(Chat chat) {
    User newuser = User();

    if (chat.idUser1 == user.id) {
      newuser.id = chat.idUser2;
      newuser.name = chat.nameUser2;
      newuser.lastname = chat.lastnameUser2;
      newuser.email = chat.emailUser2;
      newuser.phone = chat.phoneUser2;
      newuser.image = chat.imageUser2;
      newuser.notificationToken = chat.notificationTokenUser2;
    } else {
      newuser.id = chat.idUser1;
      newuser.name = chat.nameUser1;
      newuser.lastname = chat.lastnameUser1;
      newuser.email = chat.emailUser1;
      newuser.phone = chat.phoneUser1;
      newuser.image = chat.imageUser1;
      newuser.notificationToken = chat.notificationTokenUser1;
    }

    Get.toNamed('/messages', arguments: {'user': user.toJson()});
  }
}
