import 'package:flutter/material.dart';
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
  String sabor;
  List<String> valores = [];

  List<DropModel> dropDownList = <DropModel>[
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
    DropModel(id: '', name: '', price: 0.0, data: false),
  ];
  // List<D> checkList = <CheckModel>[];

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
      // print('Producto seleccionado: ${p.toJson()}');
    });

    refresh();
  }

  void addToBag() {
    // int index = selectedProducts.indexWhere((p) => p.id == product.id);

    //  dropDownList.add(findex);

    // PRODUCTOS SELECCIONADOS NO EXISTE ESE PRODUCTO
    if (product.quantity == null) {
      product.quantity = 1;
    }
    product.sabores = valores.toString();
    //  product.sabores = sabor;

    selectedProducts.add(product);

    _sharedPref.save('order', selectedProducts);
    _sharedPref.remove('features');
    _sharedPref.save('features', dropDownList);
    //  print(checkList.toString());
    Fluttertoast.showToast(msg: 'Producto agregado');
    valores = [];
    refresh();
  }

  dropValue(int index, String newData, String id) {
    dropDownList.indexWhere((element) => element.id == id);
    dropDownList[index].name = newData;

    // value = newValue;
    refresh();
  }

  /* checkBoxValue(bool value, bool newValue, int index) {
    checkList[index].data = newValue;
    print(checkList.toList());
    // value = newValue;
    refresh();
  }*/

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
