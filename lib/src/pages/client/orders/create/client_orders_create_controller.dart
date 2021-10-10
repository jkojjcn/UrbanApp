import 'package:flutter/material.dart';
import 'package:jcn_delivery/src/models/features/dropModel.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/address/list/client_address_list_page.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class ClientOrdersCreateController {
  BuildContext context;
  Function refresh;

  Product product;

  int counter = 1;
  double productPrice;

  SharedPref _sharedPref = new SharedPref();

  List<Product> selectedProducts = [];
  List<DropModel> featuresSelected;
  double total = 0;
  double distanciaDelivery;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    selectedProducts =
        Product.fromJsonList(await _sharedPref.read('order')).toList;

    featuresSelected =
        DropModel.fromJsonList(await _sharedPref.read('features')).toList;
    //  featuresSelected = jsonDecode(await _sharedPref.read('features'));
    //featuresSelected.decode(featuresSelected.json);

    getTotal();
    refresh();
  }

  void getTotal() {
    total = 0;
    selectedProducts.forEach((product) {
      total = total + (product.quantity * product.price);
    });
    refresh();
  }

  void addItem(Product product) {
    int index = selectedProducts.indexWhere((p) => p.id == product.id);
    selectedProducts[index].quantity = selectedProducts[index].quantity + 1;
    _sharedPref.save('order', selectedProducts);
    getTotal();
  }

  void removeItem(Product product) {
    if (product.quantity > 1) {
      int index = selectedProducts.indexWhere((p) => p.id == product.id);
      selectedProducts[index].quantity = selectedProducts[index].quantity - 1;
      _sharedPref.save('order', selectedProducts);
      getTotal();
    }
  }

  void deleteItem(Product product) {
    selectedProducts.remove(product);
    //  selectedProducts
    //     .removeWhere((p) => (p.features == p.features && p.id == product.id));
    _sharedPref.save('order', selectedProducts);
    getTotal();
    //  refresh();
  }

  void goToAddress(Product restaurant) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ClientAddressListPage(restaurant: restaurant)));
    /* Navigator.pushNamed(context, 'client/address/list',
        arguments: ({restaurants}));*/
  }

  restaurantDistance(_distanceRC) {
    if (_distanceRC / 1000 <= 2) {
      distanciaDelivery = 0.99;
    } else if ((_distanceRC / 1000 > 2) && (_distanceRC / 1000 <= 3)) {
      distanciaDelivery = 1.25;
    } else if ((_distanceRC / 1000 > 3) && (_distanceRC / 1000 <= 4)) {
      distanciaDelivery = 1.49;
    } else if ((_distanceRC / 1000 > 4) && (_distanceRC / 1000 <= 5)) {
      distanciaDelivery = 1.75;
    } else if ((_distanceRC / 1000 > 5) && (_distanceRC / 1000 <= 6)) {
      distanciaDelivery = 1.99;
    } else if ((_distanceRC / 1000 > 6) && (_distanceRC / 1000 <= 7)) {
      distanciaDelivery = 2.25;
    } else if ((_distanceRC / 1000 > 7) && (_distanceRC / 1000 <= 8)) {
      distanciaDelivery = 2.49;
    } else if ((_distanceRC / 1000 > 8) && (_distanceRC / 1000 <= 9)) {
      distanciaDelivery = 2.75;
    } else if ((_distanceRC / 1000 > 9) && (_distanceRC / 1000 <= 10)) {
      distanciaDelivery = 2.99;
    } else if ((_distanceRC / 1000 > 10) && (_distanceRC / 1000 <= 11)) {
      distanciaDelivery = 3.49;
    } else if ((_distanceRC / 1000 > 11) && (_distanceRC / 1000 <= 12)) {
      distanciaDelivery = 3.75;
    } else if ((_distanceRC / 1000 > 12 && (_distanceRC / 1000 <= 13))) {
      distanciaDelivery = 3.99;
    } else if ((_distanceRC / 1000 > 13) && (_distanceRC / 1000 <= 14)) {
      distanciaDelivery = 4.25;
    } else if ((_distanceRC / 1000 > 14) && (_distanceRC / 1000 <= 15)) {
      distanciaDelivery = 4.49;
    } else if ((_distanceRC / 1000 > 15) && (_distanceRC / 1000 <= 16)) {
      distanciaDelivery = 4.75;
    } else if ((_distanceRC / 1000 > 16) && (_distanceRC / 1000 <= 17)) {
      distanciaDelivery = 4.99;
    } else {
      distanciaDelivery = 5.49;
      //   return Icon(Icons.credit_card);
    }
    return Text(distanciaDelivery.toString());
  }
}
