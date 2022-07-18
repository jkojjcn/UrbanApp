import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jcn_delivery/src/models/features.dart';
import 'package:jcn_delivery/src/models/features/dropModel.dart';
import 'package:jcn_delivery/src/models/features/sabores.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/orders/create/client_orders_create_page.dart';
import 'package:jcn_delivery/src/pages/client/products/detail/client_products_detail_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'dart:convert';

import 'package:jcn_delivery/src/widgets/cart_row.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

// ignore: must_be_immutable
class ClientProductsDetailPage extends StatefulWidget {
  late Product product;
  late Product? restaurant;

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
      _con.dropDownList.clear();
      _reloadWidget();
    });
  }

  _reloadWidget() {
    Future.delayed(Duration(seconds: 1), () {
      _con.init(context, refresh, widget.product);

      _reloadWidget();
    });
  }

  String? myValue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Color.fromARGB(255, 7, 7, 7),
          height: MediaQuery.of(context).size.height * 1,
          child: ListView(
            children: [
              Hero(tag: 'productImage', child: _imageSlideshow()),
              _textName(),
              _standartDelivery(widget.product),
              _features(),
              //   _addOrRemoveItem(),
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
                BounceInDown(
                    duration: Duration(seconds: 2),
                    //     manualTrigger: true,
                    child: Icon(Icons.shopping_cart_outlined,
                        color: Colors.amber)),
                SizedBox(
                  width: 10,
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 2, left: 5, right: 5),
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.8,
                  color: Colors.transparent,
                  child: FadeIn(
                      child: CartRow(
                    selectedProducts: _con.selectedProducts,
                  )),
                ),
              ],
            ),
          ),
        ),
        Align(alignment: Alignment.bottomCenter, child: _buttonShoppingBag()),
      ],
    );
  }

  _features() {
    // _con.dropDownList.clear();
    List<Features>? listFeatures;
    ScrollController _controller0 = new ScrollController();
    List<FeaturesSabores> firstFeature = [];
    ScrollController _controller1 = new ScrollController();
    List<FeaturesSabores> secondFeature = [];
    ScrollController _controller2 = new ScrollController();
    List<FeaturesSabores> thirdFeature = [];
    ScrollController _controller3 = new ScrollController();
    try {
      final data = json.decode(_con.product!.features ?? '');

      Features sfeatures = Features.fromJsonList(data['content']);

      listFeatures = sfeatures.toListFeatures;
      print(listFeatures.length);

      try {
        FeaturesSabores dataSabores =
            FeaturesSabores.fromJsonList(listFeatures[0].content!);

        firstFeature = dataSabores.toListFeaturesSabores;
      } catch (e) {}

      try {
        FeaturesSabores dataSabores1 =
            FeaturesSabores.fromJsonList2(listFeatures[1].content!);

        secondFeature = dataSabores1.toListFeaturesSabores2;
      } catch (e) {
        print(e);
      }
      try {
        FeaturesSabores dataSabores2 =
            FeaturesSabores.fromJsonList2(listFeatures[2].content!);

        thirdFeature = dataSabores2.toListFeaturesSabores2;
      } catch (e) {
        print(e);
      }

      return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: RawScrollbar(
            trackColor: Colors.grey,
            thumbColor: Colors.amber,
            thumbVisibility: true,
            trackVisibility: true,
            controller: _controller0,
            child: ListView(
              controller: _controller0,
              children: [
                Column(
                  children: [
                    firstFeature.length >= 1
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              listFeatures[0].name! +
                                  " (Max: ${listFeatures[0].max.toString()})",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : Container(),
                    firstFeature.length >= 1
                        ? Container(
                            height: MediaQuery.of(context).size.height * 0.24,
                            width: 300,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 60, 60, 60),
                                borderRadius: BorderRadius.circular(25)),
                            child: Scrollbar(
                              thumbVisibility: true,
                              controller: _controller1,
                              trackVisibility: true,
                              child: ListView.builder(
                                  controller: _controller1,
                                  itemCount: firstFeature.length,
                                  itemBuilder: (context, index) {
                                    firstFeature.forEach((element) {
                                      if (_con.dropDownList.contains(element)) {
                                        //  print(_con.dropDownList.toList());
                                      } else {
                                        _con.dropDownList.add(DropModel(
                                            name: element.name,
                                            id: element.id,
                                            description: element.description,
                                            price: element.price,
                                            data: element.necessary));
                                      }
                                    });

                                    //  _con.dropDownList[0].name = sabores[0].name;

                                    return CheckboxListTile(
                                        //  selectedTileColor: Colors.orange,
                                        checkColor: Colors.white,
                                        enableFeedback: true,
                                        activeColor: Colors.orange,
                                        title: Text(
                                          _con.dropDownList[index].name!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        subtitle: Text(
                                            _con.dropDownList[index].description
                                                .toString(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style:
                                                TextStyle(color: Colors.white)),
                                        value: _con.dropDownList[index].data,
                                        onChanged: (boxNewvalue) {
                                          if (boxNewvalue!) {
                                            if (listFeatures![0].max! >
                                                _con.valores.length) {
                                              _con.dropDownList[index].data =
                                                  boxNewvalue;
                                              if (_con.dropDownList[index]
                                                  .data = true) {
                                                if (_con.valores.contains((_con
                                                    .dropDownList[index]
                                                    .name))) {
                                                } else {
                                                  _con.valores.add(_con
                                                      .dropDownList[index]
                                                      .name!);
                                                }
                                              } else if (_con
                                                  .dropDownList[index]
                                                  .data = false) {
                                                _con.valores.remove(_con
                                                    .dropDownList[index].name);
                                              }
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      'Máximo  ${listFeatures[0].max.toString()}');
                                            }
                                          } else {
                                            try {
                                              _con.dropDownList[index].data =
                                                  boxNewvalue;
                                              _con.valores.remove(_con
                                                  .dropDownList[index].name);
                                            } catch (e) {}
                                          }
                                          setState(() {});
                                        });
                                  }),
                            ),
                          )
                        : Container(),
                    secondFeature.length >= 2
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              listFeatures[1].name! +
                                  " (Max: ${listFeatures[1].max.toString()})",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : Container(),
                    secondFeature.length >= 2
                        ? Container(
                            height: MediaQuery.of(context).size.height * 0.24,
                            width: 300,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 60, 60, 60),
                                borderRadius: BorderRadius.circular(25)),
                            child: Scrollbar(
                              trackVisibility: true,
                              controller: _controller2,
                              thumbVisibility: true,
                              child: ListView.builder(
                                  controller: _controller2,
                                  itemCount: secondFeature.length,
                                  itemBuilder: (context, index) {
                                    secondFeature.forEach((ele) {
                                      if (!_con.supportList.contains(ele)) {
                                        _con.supportList.add(ele);
                                      } else {
                                        print("Ya esta en la lista");
                                      }
                                    });

                                    return CheckboxListTile(
                                        title: Text(
                                          _con.supportList[index].name!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        subtitle: Text(
                                          secondFeature[index].description!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        value:
                                            _con.supportList[index].necessary!,
                                        onChanged: (val) {
                                          print(_con.valores2.length);

                                          if (val == true) {
                                            if (listFeatures![1].max! >
                                                _con.valores2.length) {
                                              _con.valores2.add(
                                                  "${_con.supportList[index].name! + _con.supportList[index].description!}");
                                              _con.supportList[index]
                                                  .necessary = val;
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      'Máximo ${listFeatures[1].max}');
                                            }
                                          } else if (val == false) {
                                            _con.valores2.remove(
                                                "${_con.supportList[index].name! + _con.supportList[index].description!}");
                                            _con.supportList[index].necessary =
                                                val;
                                          }

                                          setState(() {});
                                        });
                                  }),
                            ),
                          )
                        : Container(),
                    thirdFeature.length >= 3
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              listFeatures[2].name! +
                                  " (Max: ${listFeatures[2].max.toString()})",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : Container(),
                    thirdFeature.length >= 3
                        ? Container(
                            height: MediaQuery.of(context).size.height * 0.24,
                            width: 300,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 60, 60, 60),
                                borderRadius: BorderRadius.circular(25)),
                            child: Scrollbar(
                              controller: _controller3,
                              trackVisibility: true,
                              thumbVisibility: true,
                              child: ListView.builder(
                                  controller: _controller3,
                                  itemCount: thirdFeature.length,
                                  itemBuilder: (context, index) {
                                    thirdFeature.forEach((ele) {
                                      if (!_con.supportList1.contains(ele)) {
                                        _con.supportList1.add(ele);
                                      } else {
                                        print("Ya esta en la lista");
                                      }
                                    });

                                    return CheckboxListTile(
                                        title: Text(
                                          _con.supportList1[index].name!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        subtitle: Text(
                                          thirdFeature[index].description!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        value:
                                            _con.supportList1[index].necessary!,
                                        onChanged: (val) {
                                          if (val == true) {
                                            if (listFeatures![2].max! >
                                                _con.valores3.length) {
                                              _con.valores3.add(
                                                  "${_con.supportList1[index].name! + _con.supportList1[index].description!}");
                                              _con.supportList1[index]
                                                  .necessary = val;
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      'Máximo ${listFeatures[2].max}');
                                            }
                                          } else if (val == false) {
                                            _con.valores3.remove(
                                                "${_con.supportList1[index].name! + _con.supportList1[index].description!}");
                                            _con.supportList1[index].necessary =
                                                val;
                                          }

                                          setState(() {});
                                        });
                                  }),
                            ),
                          )
                        : Container(),
                  ],
                )
              ],
            ),
          ));

      //  print(data['content'][0]['content']);

      //  return listFeatures;
    } catch (e) {}

    //  List<dynamic> dataList = jsonDecode(data.toString());

    // CATEGORIAS
    // final List<dynamic> features = jsonDecode(data);

    return Text(
      "",
      style: TextStyle(color: Colors.white),
    );
    //  print(features.id);
    //   FeaturesSabores dataSabores =
    //       FeaturesSabores.fromJsonList(features.content!);
/*
      if (features.content != null) {
        // ignore: unnecessary_null_comparison
        if (dataSabores.toListFeaturesSabores != null) {
          return Padding(
            padding: EdgeInsets.only(left: 40, right: 40),
            child: Column(
              children: [
                Text(
                  features.name!,
                  style: TextStyle(color: Colors.white),
                ),
                Text('Máximo: ' + features.max.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 12)),

                //  _dropDownWidget(dataSaboreas.toListFeaturesSabores, features),
                _checkBoxWidget(dataSabores.toListFeaturesSabores, features)
              ],
            ),
          );
        } else {
          Container();
        }
      }*/

    /*   return lista != null
        ? Text(lista[0]["0"][0]["prop1"].toString())
        : Text("No hay datos");*/
  }

  Widget _textName() {
    // print(features.toString());
    //_con.product.features.substring(start)

    return Container(
      padding: EdgeInsets.only(top: 5, left: 15),
      alignment: Alignment.centerLeft,
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
      height: MediaQuery.of(context).size.height * 0.07,
      width: MediaQuery.of(context).size.width * 0.7,
      margin: EdgeInsets.only(
          left: 30,
          right: 30,
          top: 10,
          bottom: MediaQuery.of(context).size.height * 0.09),
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
      height: MediaQuery.of(context).size.height * 0.07,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flatware,
            size: 15,
            color: Colors.grey,
          ),
          SizedBox(width: 7),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Text(
              _con.product?.description ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.white60),
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
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.25,
            child: CachedNetworkImage(
              imageUrl: _con.product!.image1!,
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
