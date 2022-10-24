import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/address.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/orderProductsModel.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/client/address/list/client_address_list_page.dart';
import 'package:jcn_delivery/src/provider/orders_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';

class ClientOrdersCreateController extends GetxController {
  late BuildContext context;

  User user = User.fromJson(GetStorage().read('user') ?? {});
  GeneralActions generalActions = Get.find();
  OrdersProvider _ordersProvider = new OrdersProvider();
  PushNotificationsProvider pushNotificationsProvider =
      PushNotificationsProvider();

  Product? product;

  List<Product> selectedProducts = [];
  double total = 0;
  double? distanciaDelivery;
  List<Product> listOrderProductsCreate = [];

  //GeneralActions generalActions = Get.put(GeneralActions());

  Future init(BuildContext context) async {
    this.context = context;
    _ordersProvider.init(context, user);

    getTotal();

    refresh();
  }

  getTotal() {
    total = 0;
    generalActions.listProductsOrder.forEach((product) {
      total = total + (1 * product.price!);
    });
    return total;
  }

  void addItem(Product product) {
    int index = selectedProducts.indexWhere((p) => p.id == product.id);
    selectedProducts[index].quantity = selectedProducts[index].quantity! + 1;
    GetStorage().write('order', selectedProducts);
    getTotal();
  }

  void removeItem(Product product) {
    if (product.quantity! > 1) {
      int index = selectedProducts.indexWhere((p) => p.id == product.id);
      selectedProducts[index].quantity = selectedProducts[index].quantity! - 1;

      generalActions.listProductsOrder.remove(product);

      GetStorage().write('order', GeneralActions().listProductsOrder);
      getTotal();
    }
  }

  void deleteItem(OrderProductModel product) {
    selectedProducts.remove(product);
    //  selectedProducts
    //     .removeWhere((p) => (p.features == p.features && p.id == product.id));
    generalActions.listProductsOrder.remove(product);

    GetStorage().write('order', GeneralActions().listProductsOrder);
    getTotal();
    //  refresh();
  }

  void goToAddress(Product restaurant) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ClientAddressListPage(restaurant: restaurant)));
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

    return Text(distanciaDelivery.toString());
  }

  void createOrder(
      String? restaurantId,
      double? distance,
      String? tokenRestaurante,
      String? masterToken,
      bool? tarjeta,
      double? priceA,
      double? priceB) async {
    Address a =
        Address.fromJson(jsonDecode(GetStorage().read('currentAddress')) ?? {});

    generalActions.listProductsOrder.forEach((prod) {
      Product floatingProduct = Product(
        id: prod.id,
        name: prod.name,
        description: prod.description,
        image1: prod.image1,
        price: prod.price,
        quantity: 1,
        sabores: prod.features,
      );
      listOrderProductsCreate.add(floatingProduct);
    });

    User userA = User.fromJson(GetStorage().read('user'));
    Order order = new Order(
        delivery: userA,
        client: userA,
        address: a,
        idClient: userA.id,
        idAddress: a.id,
        products: listOrderProductsCreate,
        restaurantId: restaurantId,
        distance: distance,
        tarjeta: tarjeta == true ? 'Si' : 'No',
        totalCliente: tarjeta == true ? priceB : priceA);
    ResponseApi responseApi = await _ordersProvider.create(order);

    if (responseApi.success = true) {
      Map<String, dynamic> data = {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'title': 'Notificacion Restaurant',
        'body': 'Nuevo Pedido :D',
        'id_message': 'idMensaje',
        'id_chat': 'idChat',
        'url': 'specific'
      };
      pushNotificationsProvider.sendOrders(tokenRestaurante ?? '', data,
          'Nuevo Pedido Registrado', 'Nuevo Pedido Registrado');
      pushNotificationsProvider.sendOrders(masterToken ?? '', data,
          'Nuevo Pedido Registrado', 'Nuevo Pedido Registrado');

      Get.snackbar('Orden creada', "Presiona aqui para ver su estado!.",
          onTap: (_) {
        Get.offAllNamed('/client/orders/list');
      },
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 5));
      generalActions.listProductsOrder.clear();
      Get.offNamedUntil('/client/restaurants', (route) => false);
    } else {
      Get.snackbar('Error',
          "No tenemos idea de lo que esta pasando.. pero de seguro alguien de RUSH será sancionado.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
