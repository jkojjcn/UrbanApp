import 'package:flutter/material.dart';
import 'package:jcn_delivery/src/models/features/checkModel.dart';
import 'package:jcn_delivery/src/models/features/dropModel.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClientProductsDetailController {
  BuildContext context;
  Function refresh;

  Product product;

  int counter = 1;
  double productPrice;

  List<DropModel> dropDownList = <DropModel>[];
  List<CheckModel> checkList = <CheckModel>[];

  SharedPref _sharedPref = new SharedPref();

  List<Product> selectedProducts = [];

  Future init(BuildContext context, Function refresh, Product product) async {
    this.context = context;
    this.refresh = refresh;
    this.product = product;
    productPrice = product.price;

    // _sharedPref.remove('order');
    selectedProducts =
        Product.fromJsonList(await _sharedPref.read('order')).toList;

    selectedProducts.forEach((p) {
      print('Producto seleccionado: ${p.toJson()}');
    });

    refresh();
  }

  void addToBag() {
    int index = selectedProducts.indexWhere((p) => p.id == product.id);

    if (index == -1) {
      // PRODUCTOS SELECCIONADOS NO EXISTE ESE PRODUCTO
      if (product.quantity == null) {
        product.quantity = 1;
      }

      selectedProducts.add(product);
    } else {
      selectedProducts[index].quantity = counter;
    }
    checkList.forEach((element) {
   //   print(element.id);
    });

    // _sharedPref.save('order', selectedProducts);
    // _sharedPref.save('features', checkList.toString());
    //  print(checkList.toString());
    Fluttertoast.showToast(msg: 'Producto agregado');
  }

  dropValue(String value, String newValue, int index) {
    dropDownList[index].name = newValue;
    // value = newValue;
    refresh();
  }

  checkBoxValue(bool value, bool newValue, int index) {
    checkList[index].data = newValue;
    print(checkList.toList());
    // value = newValue;
    refresh();
  }

  void addItem() {
    counter = counter + 1;
    productPrice = product.price * counter;
    product.quantity = counter;
    refresh();
  }

  void removeItem() {
    if (counter > 1) {
      counter = counter - 1;
      productPrice = product.price * counter;
      product.quantity = counter;
      refresh();
    }
  }

  void close() {
    Navigator.pop(context);
  }
}
