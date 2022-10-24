import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/orderProductsModel.dart';
import 'package:jcn_delivery/src/models/sabores.dart';

import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClientProductsDetailController {
  late BuildContext context;
  late Function refresh;

  Product? product;
  int counter = 1;
  double? productPrice;
  String? sabor;

  List<String> valores = [];

  GeneralActions generalActions = Get.put(GeneralActions());

  List<Product> selectedProducts = [];

  Future init(BuildContext context, Function refresh, Product product) async {
    this.context = context;
    this.refresh = refresh;
    this.product = product;
    productPrice = product.price;

    refresh();
  }

  void addToBag(Product productoAgregado) async {
    OrderProductModel orderProductModel = OrderProductModel(
        id: productoAgregado.id,
        name: productoAgregado.name,
        description: productoAgregado.description,
        image1: product!.image1,
        features: valores.toString(),
        price: productoAgregado.price);

    generalActions.listProductsOrder.add(orderProductModel);

    productoAgregado.quantity = 1;

    selectedProducts.add(productoAgregado);

    // GetStorage().write('order', generalActions.listProductsOrder);
    valores = [];

    refresh();
  }

  void addItem() {
    counter = counter + 1;
    productPrice = product!.price! * counter;
    product!.quantity = counter;
    refresh();
  }

  void removeItem() {
    if (counter > 1) {
      counter = counter - 1;
      productPrice = product!.price! * counter;
      product!.quantity = counter;
      refresh();
    }
  }

  void close() {
    Navigator.pop(context);
  }
}
