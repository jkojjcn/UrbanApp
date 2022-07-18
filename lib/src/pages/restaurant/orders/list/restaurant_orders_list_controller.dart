import 'package:flutter/material.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/restaurant/orders/detail/restaurant_orders_detail_page.dart';
import 'package:jcn_delivery/src/provider/orders_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class RestaurantOrdersListController {
 late BuildContext context;
  SharedPref _sharedPref = new SharedPref();
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
 late Function refresh;
 late User user;

  List<String> status = ['PAGADO', 'DESPACHADO', 'EN CAMINO', 'ENTREGADO'];
  OrdersProvider _ordersProvider = new OrdersProvider();
    PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();

 late bool isUpdated;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    _ordersProvider.init(context, user);
    refresh();
  }

  Future<List<Order>> getOrders(String status) async {
    return await _ordersProvider.getByStatus(status);
  }

  Future<List<Order>> getOrdersByRestaurant(String status, String restaurantId) async {
    return await _ordersProvider.getByRestaurantId(status, restaurantId);
  }

  void openBottomSheet(Order order) async {
     showMaterialModalBottomSheet(
        context: context,
        builder: (context) => RestaurantOrdersDetailPage(order: order));

    if (!isUpdated) {
      refresh();
    }
  }
   void sendNotification(String tokenDelivery) {
    Map<String, dynamic> data = {'click_action': 'FLUTTER_NOTIFICATION_CLICK'};

    pushNotificationsProvider.sendMessage(
        tokenDelivery, data, 'PEDIDO ASIGNADO', 'te han asignado un pedido');
  }

  void logout() {
    _sharedPref.logout(context, user.id!);
  }

  void goToCategoryCreate() {
    Navigator.pushNamed(context, 'restaurant/categories/create');
  }

  void goToProductCreate() {
    Navigator.pushNamed(context, 'restaurant/products/create');
  }

  void openDrawer() {
    key.currentState?.openDrawer();
  }

  void goToRoles() {
    Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
  }
}
