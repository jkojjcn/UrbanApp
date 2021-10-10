import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jcn_delivery/src/models/features.dart';
import 'package:jcn_delivery/src/models/features/dropModel.dart';
import 'package:jcn_delivery/src/models/features/sabores.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/orders/create/client_orders_create_controller.dart';
import 'package:jcn_delivery/src/pages/client/orders/create/client_orders_create_page.dart';
import 'package:jcn_delivery/src/pages/client/products/detail/client_products_detail_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'dart:convert';

import 'package:jcn_delivery/src/widgets/cart_row.dart';

// ignore: must_be_immutable
class ClientProductsDetailPage extends StatefulWidget {
  Product product;
  Product restaurant;

  ClientProductsDetailPage({Key key, @required this.product, this.restaurant})
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
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, widget.product);
      _con.dropDownList.clear();
      _reloadWidget();
    });
  }

  _reloadWidget() {
    Future.delayed(Duration(seconds: 2), () {
      _con.init(context, refresh, widget.product);
      _reloadWidget();
    });
  }

  String myValue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          height: MediaQuery.of(context).size.height * 1,
          child: ListView(
            children: [
              _imageSlideshow(),
              _textName(),
              _standartDelivery(widget.product),
              _features(),
              //   _addOrRemoveItem(),
              _buttonShoppingBag(),
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
                Icon(Icons.shopping_cart_outlined, color: Colors.orange),
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.9,
                  color: Colors.black,
                  child: FadeIn(
                      child: CartRow(
                    selectedProducts: _con.selectedProducts,
                  )),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  _features() {
    // _con.dropDownList.clear();

    try {
      final data = json.decode(_con.product.features); // CATEGORIAS
      Features features = Features.fromJson(data);
      //  print(features.id);
      FeaturesSabores dataSaboreas =
          FeaturesSabores.fromJsonList(features.content);

      if (features.content != null && features.id != "dropbutton") {
        if (dataSaboreas.toListFeaturesSabores != null) {
          return Padding(
            padding: EdgeInsets.only(left: 40, right: 40),
            child: Column(
              children: [
                _dropDownWidget(dataSaboreas.toListFeaturesSabores, features)
              ],
            ),
          );
        } else {
          Container();
        }
      } else if (features.id != "checkBox") {
        if (dataSaboreas.toListFeaturesSabores != null) {
          return Padding(
            padding: EdgeInsets.only(left: 40, right: 40),
            child: Column(
              children: [
                Text(
                  features.name,
                  style: TextStyle(color: Colors.white),
                ),
                _checkBoxWidget(dataSaboreas.toListFeaturesSabores)
              ],
            ),
          );
        } else {
          Container();
        }
        //  return Text("---");
      }

      return Text("---");

      /*   return lista != null
        ? Text(lista[0]["0"][0]["prop1"].toString())
        : Text("No hay datos");*/

    } catch (e) {
      return Container();
    }
  }

  _checkBoxWidget(List<FeaturesSabores> sabores) {
    var items = sabores.map((element) {
      return DropdownMenuItem(value: element.name, child: Text(element.name));
    }).toList();
    //print(items.toString());

    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: 400,
      color: Colors.black,
      child: ListView.builder(
          itemCount: sabores.length,
          itemBuilder: (context, index) {
            sabores.forEach((element) {
              if (_con.dropDownList.contains(element)) {
                //  print(_con.dropDownList.toList());
              } else {
                _con.dropDownList.add(DropModel(
                    name: element.name,
                    id: element.id,
                    price: element.price,
                    data: element.necessary));
              }
            });

            //  _con.dropDownList[0].name = sabores[0].name;
            bool initialValue = sabores[0].necessary;
            return CheckboxListTile(
                //  selectedTileColor: Colors.orange,
                checkColor: Colors.white,
                activeColor: Colors.orange,
                title: Text(
                  _con.dropDownList[index].name,
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(_con.dropDownList[index].price.toString(),
                    style: TextStyle(color: Colors.white)),
                value: _con.dropDownList[index].data,
                onChanged: (boxNewvalue) {
                  //          _con.dropValue(
                  //              index, boxNewvalue, _con.dropDownList[index].id);
                });
          }),
    );
  }

  _dropDownWidget(List<FeaturesSabores> sabores, features) {
    //String initialValue = "as";
    var items = sabores.map((element) {
      return DropdownMenuItem(value: element.name, child: Text(element.name));
    }).toList();
    // print(items.toString());
    sabores.forEach((element) {
      if (_con.dropDownList.contains(element)) {
        //   print(_con.dropDownList.toList());
      } else {
        _con.dropDownList.add(DropModel(
            name: element.name,
            id: _con.counter.toString(),
            price: element.price,
            data: element.necessary));
      }
    });

    return _columnDropList(sabores, features, items);

    /*  if (sabores.length == 0) {
      return _dropDown(sabores, _con.dropDownValue, sabores.length);
    } else if (sabores.length == 1) {
    } */
  }

  Widget _columnDropList(
      List<FeaturesSabores> sabores, Features features, items) {
    return Column(
      children: [
        Text(
          features.name,
          style: TextStyle(color: Colors.white),
        ),
        Container(
          height: 50 * features.max.toDouble(),
          width: MediaQuery.of(context).size.width * 0.8,
          child: ListView.builder(
              itemCount: features.max,
              itemBuilder: (context, index) {
                _con.dropDownList.add(DropModel(
                    id: sabores[index].id,
                    name: sabores[index].name,
                    price: sabores[index].price,
                    data: false));
                //  _con.dropDownList[0].name = sabores[0].name;
                String initialValue = sabores[0].name;
                return ListTile(
                  title: Text(sabores[index].id,
                      style: TextStyle(color: Colors.white)),
                  trailing: DropdownButton(

                      //   key: Key(id),
                      icon: Icon(Icons.add_outlined),
                      value: _con.dropDownList[index].name ?? initialValue,
                      style: TextStyle(color: Colors.green),
                      onChanged: (newValue) {
                        _con.valores
                            .indexWhere((element) => element != newValue);
                        _con.valores.add(newValue);

                        //  print(myValue);
                        _con.dropValue(
                            index, newValue, _con.dropDownList[index].id);
                        //     _con.dropValue(initialValue, newValue, index, false, false);
                        //    _con.dropValue(value, newValue, cantidad);
                      },
                      items: items),
                );
              }),
        ),
      ],
    );
  }

  Widget _textName() {
    // print(features.toString());
    //_con.product.features.substring(start)

    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(right: 30, left: 30, top: 30),
      child: Text(
        _con.product?.name ?? '',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 15,
            fontFamily: 'MontserratSemiBold',
            color: Colors.white),
      ),
    );
  }

  Widget _buttonShoppingBag() {
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 30),
      child: ElevatedButton(
        onPressed: () {
          _con.addToBag();
          _con.init(context, refresh, widget.product);
          //   setState(() {});
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

  Widget _standartDelivery(Product product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.flatware,
            size: 15,
            color: Colors.grey,
          ),
          SizedBox(width: 7),
          Text(
            _con.product?.description ?? '',
            style: TextStyle(fontSize: 13, color: Colors.white60),
          ),
        ],
      ),
    );
  }

/*  Widget _addOrRemoveItem() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: [
          IconButton(
              onPressed: _con.removeItem,
              icon: Icon(
                Icons.remove_circle_outline,
                color: Colors.white,
                size: 30,
              )),
          Text(
            '${_con.counter}',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          IconButton(
              onPressed: _con.addItem,
              icon: Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 30,
              )),
          Spacer(),
          Container(
            margin: EdgeInsets.only(right: 10),
            child: FadeIn(
              child: Text(
                '${_con.productPrice?.toStringAsFixed(2) ?? 0}\$',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }*/

  Widget _imageSlideshow() {
    return SafeArea(
      child: Stack(
        children: [
          ImageSlideshow(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.3,
            initialPage: 0,
            isLoop: true,
            autoPlayInterval: 6000,
            indicatorColor: MyColors.primaryColor,
            indicatorBackgroundColor: Colors.grey,
            children: [
              FadeIn(
                duration: Duration(milliseconds: 1500),
                child: FadeInImage(
                  //    fadeOutCurve: Curves.bounceIn,
                  //    fadeOutDuration: Duration(seconds: 1),
                  image: _con.product?.image1 != null
                      ? NetworkImage(_con.product.image1)
                      : AssetImage('assets/img/no-image.png'),
                  fit: BoxFit.cover,
                  fadeInDuration: Duration(milliseconds: 50),
                  placeholder: AssetImage('assets/img/no-image.png'),
                ),
              ),
              FadeIn(
                duration: Duration(milliseconds: 1500),
                child: FadeInImage(
                  image: _con.product?.image2 != null
                      ? NetworkImage(_con.product.image2)
                      : AssetImage('assets/img/no-image.png'),
                  fit: BoxFit.cover,
                  fadeInDuration: Duration(milliseconds: 50),
                  placeholder: AssetImage('assets/img/no-image.png'),
                ),
              ),
              FadeIn(
                duration: Duration(milliseconds: 1500),
                child: FadeInImage(
                  image: _con.product?.image3 != null
                      ? NetworkImage(_con.product.image3)
                      : AssetImage('assets/img/no-image.png'),
                  fit: BoxFit.cover,
                  fadeInDuration: Duration(milliseconds: 50),
                  placeholder: AssetImage('assets/img/no-image.png'),
                ),
              ),
            ],
            onPageChanged: (value) {
              //   print('Page changed: $value');
            },
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

  void refresh() {
    setState(() {});
  }
}
