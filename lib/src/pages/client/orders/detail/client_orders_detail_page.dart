import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/orders/detail/client_orders_detail_controller.dart';
import 'package:jcn_delivery/src/utils/relative_time_util.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ClientOrdersDetailPage extends StatefulWidget {
  Order order;

  ClientOrdersDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  _ClientOrdersDetailPageState createState() => _ClientOrdersDetailPageState();
}

class _ClientOrdersDetailPageState extends State<ClientOrdersDetailPage> {
  ClientOrdersDetailController _con = new ClientOrdersDetailController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, widget.order);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Orden # ${widget.order.id}'),
          actions: [
            Container(
              margin: EdgeInsets.only(top: 18, right: 15),
              child: Text(
                '${widget.order.totalCliente?.toStringAsFixed(2)} \$',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            )
          ],
        ),
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Divider(
                  color: Colors.grey[400],
                  endIndent: 30, // DERECHA
                  indent: 30, //IZQUIERDA
                ),
                SizedBox(height: 10),
                widget.order.delivery?.name != null
                    ? ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(widget.order.delivery?.image ?? ""),
                        ),
                        trailing: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: TextButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        title:
                                            Text('Contactar al repartidor/a'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  _con.order.delivery?.image ??
                                                      ""),
                                            ),
                                            Text(
                                                '${widget.order.delivery?.name ?? 'Asignando..'} ${widget.order.delivery?.lastname ?? ''}'),
                                          ],
                                        ),
                                        actions: [
                                          Column(
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    openwhatsapp(widget
                                                        .order.delivery!.phone);
                                                  },
                                                  child: Text(
                                                    'WhatsApp',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.greenAccent),
                                                  )),
                                              TextButton(
                                                  onPressed: () {
                                                    openTelf(widget
                                                        .order.delivery?.phone);
                                                  },
                                                  child: Text('Llamada')),
                                              TextButton(
                                                  onPressed: () {
                                                    Clipboard.setData(
                                                            ClipboardData(
                                                                text: widget
                                                                    .order
                                                                    .delivery
                                                                    ?.phone))
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
                                        ]);
                                  });
                            },
                            child: Text(
                              'Contactar',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ),
                        title: Text(
                            '${widget.order.delivery?.name ?? 'Asignando..'} ${widget.order.delivery?.lastname ?? ''}'),
                        subtitle: Text(
                          'Repartidor/a',
                          maxLines: 2,
                        ),
                      )
                    : Container(),
                _textData('Entregar en:',
                    '${widget.order.address.neighborhood ?? ''}'),
                _textData('Orden creada:',
                    '${RelativeTimeUtil.getTipicTime(widget.order.timestamp ?? 0)}'),
                widget.order.status == 'EN CAMINO' ? _buttonNext() : Container()
              ],
            ),
          ),
        ),
        body: ListView(
          children: widget.order.products.map((Product product) {
            return _cardProduct(product);
          }).toList(),
        ));
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
    var whatsappURlA =
        "whatsapp://send?phone=" + "+593" + number! + "&text=hello";
    var whatappURLI = "https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
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

  Widget _textData(String title, String content) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      //width: MediaQuery.of(context).size.w,
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
        onPressed: _con.updateOrder,
        style: ElevatedButton.styleFrom(
            primary: Colors.blue,
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
                  'SEGUIR ENTREGA',
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
                  Icons.directions_car,
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
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _imageProduct(product),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name ?? '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  product.description ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
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
