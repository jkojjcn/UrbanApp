import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/products/list/client_products_list_controller.dart';
import 'package:jcn_delivery/src/pages/restaurant/orders/detail/restaurant_orders_detail_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/utils/relative_time_util.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';
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

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, widget.order);
      _clientProductsListController.init(
          context, refresh, widget.order.restaurant!.id!);
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
          )
        ],
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.5,
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
              widget.order.status != 'PAGADO' ? _deliveryData() : Container(),
              _con.productsAvariable.length == 0
                  ? (widget.order.status == 'PAGADO'
                      ? _countDownTimer()
                      : Container())
                  : FloatingActionButton.extended(
                      heroTag: 'ChangeProduct',
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Text('Cambiar Producto'),
                                content: Text(
                                    'Afirmo que el cliente conoce del cambio o eliminación de producto de esta orden. \n - Puede demorar hasta 5 min el cambio. \n - Unicamente con los productos registrados.'),
                                actions: [
                                  Column(
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            openwhatsapp('0998041037');
                                          },
                                          child: Text(
                                            'Solicitar por Whatsapp',
                                            style:
                                                TextStyle(color: Colors.orange),
                                          )),
                                      TextButton(
                                          onPressed: () {
                                            openTelf('0998041037');
                                          },
                                          child: Text(
                                            'Solicitar por llamada',
                                            style:
                                                TextStyle(color: Colors.orange),
                                          )),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancelar'))
                                    ],
                                  )
                                ],
                              );
                            });
                      },
                      label: Text('Solicitar cambio de producto')),

              //   widget.order.status == 'PAGADO'
              //      ? _dropDown(_con.users)
              //     : Container(),
              _textData('Cliente:',
                  '${widget.order.client.name} ${widget.order.client.lastname}'),
              _textData('Entregar en:', '${widget.order.address.address}'),
              _textData('Fecha de pedido:',
                  '${RelativeTimeUtil.getTipicTime(widget.order.timestamp!)}'),
              widget.order.status == 'PAGADO' ? _buttonNext() : Container(),
              Text('CONTACTOS'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text('CLIENTE'),
                      TextButton(
                          onPressed: () {
                            openwhatsapp(widget.order.client.phone);
                          },
                          child: Text(
                            'WhatsApp',
                            style: TextStyle(color: Colors.greenAccent),
                          )),
                      TextButton(
                          onPressed: () {
                            openTelf(widget.order.client.phone);
                          },
                          child: Text('Llamada')),
                      TextButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                    text: widget.order.client.phone))
                                .then((value) {
                              //only if ->
                              Fluttertoast.showToast(
                                  msg:
                                      'Texto Copiado'); // -> show a notification
                            });
                          },
                          child: Text('Copiar número'))
                    ],
                  ),
                  Container(height: 120, width: 1, color: Colors.black),
                  Column(
                    children: [
                      Text('REPARTIDOR/A'),
                      TextButton(
                          onPressed: () {
                            openwhatsapp(widget.order.delivery!.phone!);
                          },
                          child: Text(
                            'WhatsApp',
                            style: TextStyle(color: Colors.greenAccent),
                          )),
                      TextButton(
                          onPressed: () {
                            openTelf(widget.order.delivery!.phone!);
                          },
                          child: Text('Llamada')),
                      TextButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                    text: widget.order.delivery!.phone!))
                                .then((value) {
                              //only if ->
                              Fluttertoast.showToast(
                                  msg:
                                      'Texto Copiado'); // -> show a notification
                            });
                          },
                          child: Text('Copiar número'))
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
      body: widget.order.products.length > 0
          ? ListView(
              children: widget.order.products.map((Product product) {
                return _cardProduct(product);
              }).toList(),
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
        widget.order.status == 'PAGADO' ? 'Tiempo de preparación ' : 'Delivery',
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

  openwhatsapp(String? number) async {
    var whatsapp = number;
    var whatsappURlAndroid =
        "whatsapp://send?phone=" + "+593" + number! + "&text=hello";
    var whatappURLIos = "https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
    if (Platform.isIOS) {
      // for iOS phone only
      // ignore: deprecated_member_use
      if (await canLaunch(whatappURLIos)) {
        // ignore: deprecated_member_use
        await launch(whatappURLIos, forceSafariVC: false);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    } else {
      // android , web
      // ignore: deprecated_member_use
      if (await canLaunch(whatsappURlAndroid)) {
        // ignore: deprecated_member_use
        await launch(whatsappURlAndroid);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    }
  }

/*
  Widget _dropDown(List<User> users) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Material(
        elevation: 2.0,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Container(
          padding: EdgeInsets.all(0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButton(
                  underline: Container(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_drop_down_circle,
                      color: MyColors.primaryColor,
                    ),
                  ),
                  elevation: 3,
                  isExpanded: true,
                  hint: Text(
                    'Repartidores',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  items: _dropDownItems(users),
                  value: _con.idDelivery,
                  onChanged: (option) {
                    setState(() {
                      print('Reparidor selecciondo $option');
                      _con.idDelivery =
                          option; // ESTABLECIENDO EL VALOR SELECCIONADO
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }*/

  Widget _deliveryData() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            child: widget.order.delivery?.image != null
                ? FadeInImage(
                    image: NetworkImage(widget.order.delivery?.image ?? ""),
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(milliseconds: 50),
                    placeholder: AssetImage('assets/img/no-image.png'),
                  )
                : Image.asset('assets/img/no-image.png'),
          ),
          SizedBox(width: 5),
          Text(
              '${widget.order.delivery!.name} ${widget.order.delivery!.lastname}')
        ],
      ),
    );
  }

  /* List<DropdownMenuItem<String>> _dropDownItems(List<User> users) {
    List<DropdownMenuItem<String>> list = [];
    users.forEach((user) {
      list.add(DropdownMenuItem(
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              child: FadeInImage(
                image:NetworkImage(user.image)
                   ,
                fit: BoxFit.cover,
                fadeInDuration: Duration(milliseconds: 50),
                placeholder: AssetImage('assets/img/no-image.png'),
              ),
            ),
            SizedBox(width: 5),
            Text(user.name)
          ],
        ),
        value: user.id,
      ));
    });

    return list;
  }*/

  Widget _textData(String title, String content) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          content,
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _buttonNext() {
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 20),
      child: ElevatedButton(
        onPressed: () {
          _con.time = _value;
          _con.updateOrder();
          _con.createNotification();
        },
        style: ElevatedButton.styleFrom(
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

  Widget _cardProduct(Product product) {
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
          widget.order.status == 'PAGADO'
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Checkbox(
                      value: product.available == 0 ? false : true,
                      onChanged: (newValue) {
                        if (newValue!) {
                          product.available = 1;
                          _con.productsAvariable.remove(product);
                        } else {
                          product.available = 0;
                          _con.productsAvariable.add(product);
                        }
                        setState(() {});
                        print(_con.productsAvariable.length);
                      }))
              : Container()
        ],
      ),
    );
  }

  Widget _imageProduct(Product product) {
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
