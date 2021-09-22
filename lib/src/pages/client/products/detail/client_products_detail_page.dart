import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jcn_delivery/src/models/features.dart';
import 'package:jcn_delivery/src/models/features/checkModel.dart';
import 'package:jcn_delivery/src/models/features/dropModel.dart';
import 'package:jcn_delivery/src/models/features/sabores.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/products/detail/client_products_detail_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'dart:convert';

class ClientProductsDetailPage extends StatefulWidget {
  Product product;

  ClientProductsDetailPage({Key key, @required this.product}) : super(key: key);

  @override
  _ClientProductsDetailPageState createState() =>
      _ClientProductsDetailPageState();
}

class _ClientProductsDetailPageState extends State<ClientProductsDetailPage> {
  ClientProductsDetailController _con = new ClientProductsDetailController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, widget.product);
    });
  }

  var _checkItems = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: MediaQuery.of(context).size.height * 1,
      child: ListView(
        children: [
          _imageSlideshow(),
          _textName(),
          _standartDelivery(widget.product),
          _features(),
          _addOrRemoveItem(),
          _buttonShoppingBag()
        ],
      ),
    );
  }

  _features() {
    try {
      final data = json.decode(_con.product.features); // CATEGORIAS
      Features features = Features.fromJson(data);
      print(features.id);
      FeaturesSabores dataSaboreas =
          FeaturesSabores.fromJsonList(features.content);

      if (features.content != null && features.id == "dropbutton") {
        if (dataSaboreas.toListFeaturesSabores != null) {
          return Padding(
            padding: EdgeInsets.only(left: 40, right: 40),
            child: Column(
              children: [
                Text(
                  features.name,
                  style: TextStyle(color: Colors.white),
                ),
                _dropDownWidget(dataSaboreas.toListFeaturesSabores)
              ],
            ),
          );
        } else {
          Container();
        }
      } else if (features.id == "checkBox") {
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
    print(items.toString());

    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: 400,
      color: Colors.black,
      child: ListView.builder(
          itemCount: sabores.length,
          itemBuilder: (context, index) {
            _con.checkList.add(CheckModel(
                index, sabores[index].necessary, sabores[index].price));
            //  _con.dropDownList[0].name = sabores[0].name;
            bool initialValue = sabores[0].necessary;
            return CheckboxListTile(
              //  selectedTileColor: Colors.orange,
                checkColor: Colors.white,
                activeColor: Colors.orange,
                title: Text(
                  sabores[index].name,
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(sabores[index].price.toString(),
                    style: TextStyle(color: Colors.white)),
                value: _con.checkList[index].data ?? initialValue,
                onChanged: (boxNewvalue) {
                  _con.checkBoxValue(initialValue, boxNewvalue, index);
                });

            /*return ListTile(
              title: Text(sabores[index].id),
              trailing: DropdownButton(
                  //   key: Key(id),
                  icon: Icon(Icons.add_outlined),
                  value: _con.dropDownList[index].name ?? initialValue,
                  onChanged: (newValue) {
                    _con.dropValue(initialValue, newValue, index);
                    //    _con.dropValue(value, newValue, cantidad);
                  },
                  items: items),
            );*/
          }),
    );
  }

  _dropDownWidget(List<FeaturesSabores> sabores) {
    //String initialValue = "as";
    var items = sabores.map((element) {
      return DropdownMenuItem(value: element.name, child: Text(element.name));
    }).toList();
    print(items.toString());

    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: 400,
      child: ListView.builder(
          itemCount: sabores.length,
          itemBuilder: (context, index) {
            _con.dropDownList.add(
                DropModel(index, sabores[index].name, sabores[index].price));
            //  _con.dropDownList[0].name = sabores[0].name;
            String initialValue = sabores[0].name;
            return ListTile(
              title: Text(sabores[index].id),
              trailing: DropdownButton(
                  //   key: Key(id),
                  icon: Icon(Icons.add_outlined),
                  value: _con.dropDownList[index].name ?? initialValue,
                  onChanged: (newValue) {
                    _con.dropValue(initialValue, newValue, index);
                    //    _con.dropValue(value, newValue, cantidad);
                  },
                  items: items),
            );
          }),
    );

    /*  if (sabores.length == 0) {
      return _dropDown(sabores, _con.dropDownValue, sabores.length);
    } else if (sabores.length == 1) {
    } */
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
        onPressed: _con.addToBag,
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

  Widget _addOrRemoveItem() {
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
  }

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
              print('Page changed: $value');
            },
          ),
          FadeIn(
            child: Positioned(
                left: 5,
                top: 30,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  }, //_con.close,
                  icon: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
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
          ),
        ],
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
