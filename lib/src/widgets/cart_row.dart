import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/orders/create/client_orders_create_controller.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';

// ignore: must_be_immutable
class CartRow extends StatefulWidget {
  List<Product> selectedProducts = [];

  CartRow({Key? key, required this.selectedProducts}) : super(key: key);
  @override
  _CartRowState createState() => _CartRowState();
}

class _CartRowState extends State<CartRow> {
  ClientOrdersCreateController _con = new ClientOrdersCreateController();
  SharedPref _sharedPref = new SharedPref();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      _con.init(context, refresh);
      _updateWidget();
    });
    super.initState();
  }

  List<Product> seleccionados = [];

  _updateWidget() {
    Future.delayed(Duration(seconds: 1), () {
      selectedProducts();
      setState(() {});
      _updateWidget();
      //  print('recargado');
    });
  }

  selectedProducts() async {
    seleccionados =
        Product.fromJsonList(await _sharedPref.read('order')).toList;
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: seleccionados
          .map((e) => BounceInDown(
                child: Padding(
                  padding: EdgeInsets.only(left: 4, right: 4),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(e.image1!),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
