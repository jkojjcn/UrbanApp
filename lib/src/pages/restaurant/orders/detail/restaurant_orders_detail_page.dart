import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/orderProductsModel.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/client/products/list/client_products_list_controller.dart';
import 'package:jcn_delivery/src/pages/restaurant/orders/detail/restaurant_orders_detail_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/utils/relative_time_util.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class RestaurantOrdersDetailPage extends StatefulWidget {
  Order order;

  RestaurantOrdersDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  _RestaurantOrdersDetailPageState createState() =>
      _RestaurantOrdersDetailPageState();
}

class _RestaurantOrdersDetailPageState
    extends State<RestaurantOrdersDetailPage> {
  RestaurantOrdersDetailController _con =
      new RestaurantOrdersDetailController();
  ClientProductsListController _clientProductsListController =
      new ClientProductsListController();
  double _value = 10.0;
  String urlRushImage = "https://i.ibb.co/7V3mqx4/logoIOS.png";

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, widget.order);
      _clientProductsListController.init(
          context, refresh, widget.order.restaurant?.id ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orden #${widget.order.id}'),
        actions: [
          Container(
            margin: EdgeInsets.only(top: 18, right: 15),
            child: Text(
              'Total: ${_con.total.toStringAsFixed(2)}\$',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          widget.order.tarjeta == 'Si'
              ? Align(
                  alignment: Alignment.topRight, child: Icon(Icons.credit_card))
              : Container()
        ],
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Divider(
                color: Colors.grey[400],
                endIndent: 30, // DERECHA
                indent: 30, //IZQUIERDA
              ),
              SizedBox(height: 10),
              _textDescription(),
              SizedBox(height: 15),
              widget.order.status != 'PAGADO'
                  ? widget.order.delivery!.name != null &&
                          widget.order.delivery!.name != ''
                      ? _userData(widget.order.delivery!)
                      : Container()
                  : Container(),
              Text(
                'Cliente',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: MyColors.primaryColor,
                    fontSize: 16),
              ),
              (widget.order.status == 'PAGADO'
                  ? _countDownTimer()
                  : Container()),
              _userData(widget.order.client),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timelapse_rounded),
                  Text(
                      '${RelativeTimeUtil.getTipicTime(widget.order.timestamp!)}')
                ],
              ),
              widget.order.status == 'PAGADO' ? _buttonNext() : Container(),
            ],
          ),
        ),
      ),
      body: widget.order.productsOrder != null
          ? widget.order.productsOrder!.length > 0
              ? ListView(
                  children: widget.order.productsOrder!
                      .map((OrderProductModel product) {
                    return _cardProduct(product);
                  }).toList(),
                )
              : NoDataWidget(
                  text: 'Ningun producto agregado',
                )
          : NoDataWidget(
              text: 'Ningun producto agregado',
            ),
    );
  }

  Widget _countDownTimer() {
    return SfSlider(
      min: 0.0,
      max: 60.0,
      value: _value,
      stepSize: 5,
      interval: 20,
      showTicks: true,
      showLabels: true,
      enableTooltip: true,
      minorTicksPerInterval: 1,
      onChanged: (dynamic value) {
        setState(() {
          _value = value;
        });
      },
    );
  }

  Widget _textDescription() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        widget.order.status == 'PAGADO' ? 'Tiempo de preparación ' : '',
        style: TextStyle(
            fontStyle: FontStyle.italic,
            color: MyColors.primaryColor,
            fontSize: 16),
      ),
    );
  }

  openTelf(String? number) async {
    var whatsappURlA = "tel://$number";
    var whatappURLI = "tel://$number";
    if (Platform.isIOS) {
      // for iOS phone only
      // ignore: deprecated_member_use
      if (await canLaunch(whatappURLI)) {
        // ignore: deprecated_member_use
        await launch(whatappURLI, forceSafariVC: false);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    } else {
      // android , web
      // ignore: deprecated_member_use
      if (await canLaunch(whatsappURlA)) {
        // ignore: deprecated_member_use
        await launch(whatsappURlA);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    }
  }

  Widget _userData(User userData) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            //  width: MediaQuery.of(context).size.width * 0.7,
            child: Row(
              children: [
                userData.image != null
                    ? Container(
                        width: 50,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl:
                                  userData.image != null && userData.image != ''
                                      ? userData.image!
                                      : urlRushImage,
                              placeholder: (context, url) => Shimmer(
                                  child: Container(
                                color: Colors.black,
                              )),
                              imageBuilder: (context, image) => Image(
                                image: image,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(width: 5),
                Text('${userData.name}')
              ],
            ),
          ),
          Container(
            child: TextButton(
                onPressed: () {
                  _showContactMethod(userData);
                },
                child: Text('Contactar')),
          )
        ],
      ),
    );
  }

  _showContactMethod(User user) {
    return showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Contacta a ${user.name} '),
            actions: [
              TextButton(
                  onPressed: () {
                    openTelf(user.phone);
                  },
                  child: Text('Llamada')),
              TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: user.phone))
                        .then((value) {
                      //only if ->
                      Fluttertoast.showToast(
                          msg: 'Texto Copiado'); // -> show a notification
                    });
                  },
                  child: Text('Copiar número')),
              TextButton(
                  onPressed: () {
                    _con.createChat(user);
                  },
                  child: Text('Chat'))
            ],
          );
        });
  }

  Widget _buttonNext() {
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 20),
      child: ElevatedButton(
        onPressed: () {
          _con.time = _value;
          _con.updateOrder();
        },
        style: ElevatedButton.styleFrom(
            // ignore: deprecated_member_use
            primary: MyColors.primaryColor,
            padding: EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  'PREPARAR',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 50, top: 4),
                height: 30,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _cardProduct(OrderProductModel product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Stack(
        children: [
          Row(
            children: [
              _imageProduct(product),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      '${product.name ?? ""}!',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      product.features != "[]" ? '${product.features}' : "",
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageProduct(OrderProductModel product) {
    return Container(
      width: 50,
      height: 50,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.grey[200]),
      child: FadeInImage(
        image: NetworkImage(product.image1!),
        fit: BoxFit.contain,
        fadeInDuration: Duration(milliseconds: 50),
        placeholder: AssetImage('assets/img/no-image.png'),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
