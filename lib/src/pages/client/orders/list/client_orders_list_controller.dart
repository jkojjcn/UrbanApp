import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/client/orders/detail/client_orders_detail_page.dart';
import 'package:jcn_delivery/src/provider/orders_provider.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ClientOrdersListController {
  late BuildContext context;

  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  late Function refresh;
  late User user;

  List<String> status = ['PAGADO', 'DESPACHADO', 'EN CAMINO', 'ENTREGADO'];
  OrdersProvider _ordersProvider = new OrdersProvider();

  bool? isUpdated;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(GetStorage().read('user'));

    log('Inicio de orden init');

    _ordersProvider.init(context, user);
    refresh();
  }

  Future<List<Order>> getOrders(String status) async {
    log('Intentando traer las ordenes');

    return await _ordersProvider.getByClientAndStatus(status);
  }

  void openBottomSheet(Order order) async {
    isUpdated = await showMaterialModalBottomSheet(
        context: context,
        builder: (context) => ClientOrdersDetailPage(order: order));

    if (isUpdated ?? false) {
      refresh();
    }
  }

  void logout() async {
    UsersProvider usersProvider = new UsersProvider();
    usersProvider.init(
      context,
    );
    await usersProvider.logout(user.id!);
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
    Get.offAllNamed('/roles');
  }
}
