import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/orders/create/client_orders_create_controller.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:phlox_animations/phlox_animations.dart';

// ignore: must_be_immutable
class CartRow extends StatefulWidget {
  List<Product> selectedProducts = [];

  CartRow({Key? key, required this.selectedProducts}) : super(key: key);
  @override
  _CartRowState createState() => _CartRowState();
}

class _CartRowState extends State<CartRow> {
  ClientOrdersCreateController _con = new ClientOrdersCreateController();
  GeneralActions generalActions = Get.find();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      _con.init(context);
    });
    super.initState();
  }

  List<Product> seleccionados = [];

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: generalActions.listProductsOrder
          .map((e) => PhloxAnimations(
                fromScale: 0,
                scaleCurve: Curves.easeInOutCubic,
                toScale: 1,
                duration: Duration(milliseconds: 400),
                child: Padding(
                  padding: EdgeInsets.only(left: 4, right: 4),
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage: NetworkImage(e.image1!),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
