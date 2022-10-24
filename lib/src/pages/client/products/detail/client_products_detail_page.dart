import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jcn_delivery/src/models/features.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/restaurant.dart';
import 'package:jcn_delivery/src/models/sabores.dart';
import 'package:jcn_delivery/src/pages/client/orders/create/client_orders_create_page.dart';
import 'package:jcn_delivery/src/pages/client/products/detail/client_products_detail_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'dart:convert';

import 'package:jcn_delivery/src/widgets/cart_row.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

// ignore: must_be_immutable
class ClientProductsDetailPage extends StatefulWidget {
  late Product product;
  late Restaurant? restaurant;

  ClientProductsDetailPage({Key? key, required this.product, this.restaurant})
      : super(key: key);

  @override
  _ClientProductsDetailPageState createState() =>
      _ClientProductsDetailPageState();
}

class _ClientProductsDetailPageState extends State<ClientProductsDetailPage> {
  ClientProductsDetailController _con = new ClientProductsDetailController();
  // ClientOrdersCreateController _conO = new ClientOrdersCreateController();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, widget.product);
    });
  }

  String? myValue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Color.fromARGB(255, 32, 32, 32),
        height: MediaQuery.of(context).size.height * 1,
        child: Stack(
          children: [
            Container(
              //  height: MediaQuery.of(context).size.height * 0.8,
              child: ListView(
                children: [
                  _imageSlideshow(),
                  SizedBox(
                    height: 15,
                  ),
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          widget.product.name ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'MontserratSemiBold',
                              color: Colors.white),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: Text(
                              widget.product.description ?? '',
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.white60),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '\$',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 34),
                                ),
                                _textPrice(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      widget.product.features != null
                          ? _featuresListView()
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ClientOrdersCreatePage(
                                restaurant: widget.restaurant,
                              )));
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.shopping_cart_outlined, color: Colors.amber),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 2, left: 5, right: 5),
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width * 0.8,
                      color: Colors.transparent,
                      child: CartRow(
                        selectedProducts: _con.selectedProducts,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter, child: _buttonShoppingBag()),
          ],
        ),
      ),
    );
  }

  Widget _featuresListView() {
    return Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(8),
        height: MediaQuery.of(context).size.height * 0.40,
        width: MediaQuery.of(context).size.width * 1,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color.fromARGB(255, 46, 46, 46)),
        child: ListView.builder(
            itemCount: widget.product.features?.content?.length ?? 0,
            itemBuilder: (context, index) {
              double? numberWidget;
              numberWidget = widget
                  .product.features?.content?[index].content!.length
                  .toDouble();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.product.features!.content![index].name ?? '',
                      style: TextStyle(fontSize: 16, color: Colors.white60),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      'Seleccione Máximo: ${widget.product.features!.content![index].max}',
                      style: TextStyle(fontSize: 12, color: Colors.white60),
                    ),
                  ),
                  numberWidget != null
                      ? Container(
                          height: 60 * numberWidget,
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: widget.product.features!
                                      .content![index].content?.length ??
                                  0,
                              itemBuilder: (context, saborIndex) {
                                return _featuresCard(widget.product.features!
                                    .content![index].content![saborIndex]);
                              }),
                        )
                      : Container()
                ],
              );
            }));
  }

  Widget _featuresCard(Sabores sabores) {
    return Container(
        height: 60,
        color:
            _con.valores.contains('${sabores.name} + ${sabores.description}') !=
                    true
                ? Color.fromARGB(255, 46, 46, 46)
                : Color.fromARGB(255, 139, 139, 139),
        child: Center(
          child: CheckboxListTile(
            value: _con.valores
                        .contains('${sabores.name} + ${sabores.description}') !=
                    true
                ? false
                : true,
            onChanged: (value) {
              sabores.addInProduct = value;

              if (value == true) {
                _con.valores.add('${sabores.name} + ${sabores.description}');
              } else {
                _con.valores.remove('${sabores.name} + ${sabores.description}');
              }
              refresh();
            },
            title: Text(
              sabores.name ?? '',
              style: TextStyle(color: Colors.white60),
            ),
            subtitle: Text(
              sabores.description ?? '..',
              style: TextStyle(color: Colors.white60),
            ),
          ),
        ));
  }

  Widget _textPrice() {
    // print(features.toString());
    //_con.product.features.substring(start)

    return Container(
      padding: EdgeInsets.only(left: 5),
      alignment: Alignment.centerLeft,
      child: Text(
        widget.product.price.toString(),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 25,
            fontFamily: 'MontserratSemiBold',
            color: Color.fromARGB(255, 220, 220, 220)),
      ),
    );
  }

  Widget _buttonShoppingBag() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.07,
      width: MediaQuery.of(context).size.width * 0.7,
      margin: EdgeInsets.only(
          left: 30,
          right: 30,
          top: 10,
          bottom: MediaQuery.of(context).size.height * 0.09),
      child: ElevatedButton(
        onPressed: () {
          _con.addToBag(widget.product);
          //    _con.init(context, refresh, widget.product);
          //   setState(() {});
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
                height: 50,
                margin: EdgeInsets.only(left: 20),
                alignment: Alignment.center,
                child: Text(
                  'AGREGAR',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MontserratMedium'),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 70, top: 10),
                height: 30,
                child: Icon(Icons.shopping_cart),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _imageSlideshow() {
    return SafeArea(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.25,
            child: CachedNetworkImage(
              imageUrl: widget.product.image1 ??
                  'https://i.ibb.co/7V3mqx4/logoIOS.png',
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
          FadeIn(
              child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            }, //_con.close,
            icon: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void refresh() {
    setState(() {});
  }
}
