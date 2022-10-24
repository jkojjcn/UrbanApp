import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/orderProductsModel.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/restaurant.dart';
import 'package:jcn_delivery/src/pages/client/address/list/client_address_list_controller.dart';
import 'package:jcn_delivery/src/pages/client/orders/create/client_orders_create_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';

// ignore: must_be_immutable
class ClientOrdersCreatePage extends StatefulWidget {
  Restaurant? restaurant;
  ClientOrdersCreatePage({Key? key, this.restaurant}) : super(key: key);

  @override
  _ClientOrdersCreatePageState createState() => _ClientOrdersCreatePageState();
}

class _ClientOrdersCreatePageState extends State<ClientOrdersCreatePage> {
  ClientOrdersCreateController _con = new ClientOrdersCreateController();

  GeneralActions con = Get.put(GeneralActions());
  bool requieredCard = false;
  bool colorBool = false;

  @override
  void initState() {
    if (widget.restaurant!.price! >= 7) {
      requieredCard = true;
      colorBool = true;
    }
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
      _con.init(context);
    });
  }

  MaterialStateProperty<Color> colorA =
      MaterialStateProperty.all<Color>(Colors.white);
  MaterialStateProperty<Color> colorB =
      MaterialStateProperty.all<Color>(Colors.green);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios)),
          title: Text('Mi orden'),
        ),
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).size.height * 0.45,
          child: Column(
            children: [
              Divider(
                color: Colors.grey[400],
                endIndent: 30, // DERECHA
                indent: 30, //IZQUIERDA
              ),
              con.listProductsOrder.length > 0
                  ? _textTotalPrice()
                  : Container(),
              con.listProductsOrder.length > 0 ? _buttonNext() : Container()
            ],
          ),
        ),
        body: con.listProductsOrder.length > 0
            ? ListView(
                children:
                    con.listProductsOrder.map((OrderProductModel product) {
                  //   print('sabor es ${product.sabores}');
                  return _cardProduct(product);
                }).toList(),
              )
            : Center(
                child: NoDataWidget(
                  text: 'Ningun producto agregado',
                ),
              ));
  }

  Widget _buttonNext() {
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, top: 1, bottom: 10),
      child: ElevatedButton(
        onPressed: () {
          Fluttertoast.showToast(msg: 'Gracias por tu compra <3');
          _con.createOrder(
              widget.restaurant?.name,
              widget.restaurant?.price,
              widget.restaurant?.notificationTokenR,
              widget.restaurant?.masterNotificationToken,
              colorBool,
              (_con.total + widget.restaurant!.price!),
              (((_con.total + widget.restaurant!.price!) * 0.08) +
                  (_con.total + widget.restaurant!.price!)));

          // _con.goToAddress(widget.restaurant);
        },
        style: ElevatedButton.styleFrom(
            // ignore: deprecated_member_use
            primary: MyColors.primaryColor,
            padding: EdgeInsets.symmetric(vertical: 2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        child: Stack(
          //mainAxisSize: MainAxisSize.max,
          //    mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /*   Align(
                alignment: Alignment.c,
                child: Image.asset(
                  'assets/iconApp/2.png',
                  width: 50,
                  height: 50,
                )),*/
            Container(
              height: 50,
              alignment: Alignment.center,
              child: Text(
                'CREAR PEDIDO',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardProduct(OrderProductModel? product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _imageProduct(product!),
          SizedBox(width: 10),
          // Text(_con.featuresSelected.length.toString()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Text(
                  product.name ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Text(
                  product.features == "[]" ? "" : product.features ?? '',
                  maxLines: 3,
                  style: TextStyle(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              )

              //_addOrRemoveItem(product)
            ],
          ),
          Spacer(),
          Column(
            children: [_textPrice(product), _iconDelete(product)],
          )
        ],
      ),
    );
  }

  Widget _iconDelete(OrderProductModel product) {
    return IconButton(
        onPressed: () {
          _con.deleteItem(product);
          refresh();
        },
        icon: Icon(
          Icons.delete,
          color: MyColors.primaryColor,
        ));
  }

  Widget _textTotalPrice() {
    _con.getTotal();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              !requieredCard
                  ? Container(
                      //    width: MediaQuery.of(context).size.width * 0.5,
                      child: TextButton(
                          style: ButtonStyle(backgroundColor: colorB),
                          onPressed: () {
                            colorBool = false;
                            colorA = MaterialStateProperty.all<Color>(
                                Colors.grey[350]!);
                            colorB =
                                MaterialStateProperty.all<Color>(Colors.green);
                            setState(() {});
                          },
                          child: Text(
                            'Efectivo',
                            style: TextStyle(color: Colors.black),
                          )))
                  : Container(),
              colorBool
                  ? FadeInRight(
                      duration: Duration(milliseconds: 400),
                      child: Icon(Icons.credit_card))
                  : FadeInLeft(
                      duration: Duration(milliseconds: 400),
                      child: Icon(Icons.payments)),

              !requieredCard
                  ? Container(
                      //   width: MediaQuery.of(context).size.width * 0.5,
                      child: TextButton(
                          style: ButtonStyle(backgroundColor: colorA),
                          onPressed: () {
                            setState(() {
                              colorBool = true;
                              colorA = MaterialStateProperty.all<Color>(
                                  Colors.green);
                              colorB = MaterialStateProperty.all<Color>(
                                  Colors.grey[350]!);
                            });
                            //  Get.toNamed(
                            //    '/payphone',
                            //  );

                            showCupertinoDialog(
                                context: context,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: Text(
                                        'Luego de crear el pedido, nuestro equipo le enviará un link de pago por nuestro chat.'),
                                    content: Icon(Icons.mail),
                                    actions: [
                                      CupertinoDialogAction(
                                          child: Text("Confirmar"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          }),
                                    ],
                                  );
                                });
                          },
                          child: Text(
                            'Tarjeta',
                            style: TextStyle(color: Colors.black),
                          )))
                  : Container()
              //   Switch(value: false, onChanged: (onChanged) {})
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                //   width: MediaQuery.of(context).size.width * 1,
                child: Text(
                  colorBool ? 'Pago con tarjeta.' : 'Pago en efectivo',
                  style: TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              )
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal:',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    '${_con.total.toStringAsFixed(2)}\$',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Repartidor:',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text('${widget.restaurant!.price!.toStringAsFixed(2)}\$')
                ],
              ),
            ],
          ),
          Column(
            children: [
              colorBool
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transacción por tarjeta (8%):',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          '${((_con.total + widget.restaurant!.price!) * 0.08).toStringAsFixed(2)}\$',
                        ),
                      ],
                    )
                  : Container(),
              FadeIn(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    !colorBool
                        ? Text(
                            '${(_con.total + widget.restaurant!.price!).toStringAsFixed(2)}\$',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          )
                        : Text(
                            '${(((_con.total + widget.restaurant!.price!) * 0.08) + (_con.total + widget.restaurant!.price!)).toStringAsFixed(2)}\$',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _textPrice(OrderProductModel product) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Text(
        '\$ ${(product.price! * 1).toStringAsFixed(2)}',
        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _imageProduct(OrderProductModel product) {
    return Container(
      width: 90,
      height: 90,
      padding: EdgeInsets.all(10),
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
