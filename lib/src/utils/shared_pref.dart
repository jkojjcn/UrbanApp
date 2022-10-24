import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/chat.dart';
import 'package:jcn_delivery/src/models/orderProductsModel.dart';
import 'package:jcn_delivery/src/models/publications.dart';
import 'package:jcn_delivery/src/models/restaurant.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';

class GeneralActions extends GetxController {
  // List<OrderProductModel> listProductsOrder = [];
  var listProductsOrder = <OrderProductModel>[].obs;
  var chats = <Chat>[].obs;
  var publications = <Publications>[].obs;
  var restaurants = <Restaurant>[].obs;
  var filterRestaurants = 'Todos'.obs;
  var filterPublications = 'Recomendados'.obs;
  var city = ''.obs;
  var userUid = User().obs;

  User user = User.fromJson(GetStorage().read('user') ?? {});

  void logout(BuildContext context, String idUser) async {
    UsersProvider usersProvider = new UsersProvider();
    usersProvider.init(
      context,
    );
    await usersProvider.logout(idUser);
    await GetStorage().remove('user');
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }

  double distancePriceSantaElena(int distance) {
    double deliveryPrice = 0;
    switch (distance) {
      case 0:
        return deliveryPrice = 1;
      case 1:
        return deliveryPrice = 1;
      case 2:
        return deliveryPrice = 1;
      case 3:
        return deliveryPrice = 1.50;
      case 4:
        return deliveryPrice = 2.00;
      case 5:
        return deliveryPrice = 2.00;
      case 6:
        return deliveryPrice = 2.25;
      case 7:
        return deliveryPrice = 2.50;
      case 8:
        return deliveryPrice = 2.75;
      case 9:
        return deliveryPrice = 3.00;
      case 10:
        return deliveryPrice = 3.25;
      case 11:
        return deliveryPrice = 3.50;
      case 12:
        return deliveryPrice = 3.75;
      case 13:
        return deliveryPrice = 4.00;
      case 14:
        return deliveryPrice = 4.25;
      case 15:
        return deliveryPrice = 4.50;

      default:
        distance = 100;
    }
    return deliveryPrice;
  }

  double distancePriceCuenca(int distance) {
    double deliveryPrice = 0;
    switch (distance) {
      case 0:
        return deliveryPrice = 1.50;
      case 1:
        return deliveryPrice = 1.50;
      case 2:
        return deliveryPrice = 1.50;
      case 3:
        return deliveryPrice = 1.75;
      case 4:
        return deliveryPrice = 2.25;
      case 5:
        return deliveryPrice = 2.75;
      case 6:
        return deliveryPrice = 3.25;
      case 7:
        return deliveryPrice = 3.75;
      case 8:
        return deliveryPrice = 4.25;
      case 9:
        return deliveryPrice = 4.75;
      case 10:
        return deliveryPrice = 5.25;
      case 11:
        return deliveryPrice = 5.75;
      case 12:
        return deliveryPrice = 6.25;
      case 13:
        return deliveryPrice = 6.75;
      case 14:
        return deliveryPrice = 7.25;
      case 15:
        return deliveryPrice = 7.75;

      default:
        distance = 100;
    }
    return deliveryPrice;
  }
}
