import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jcn_delivery/src/models/category.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/products/restaurant/restaurants_list_controller.dart';
import 'package:jcn_delivery/src/pages/restaurant/products/create/restaurant_products_create_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';

class RestaurantProductsCreatePage extends StatefulWidget {
  const RestaurantProductsCreatePage({Key? key}) : super(key: key);

  @override
  _RestaurantProductsCreatePageState createState() =>
      _RestaurantProductsCreatePageState();
}

class _RestaurantProductsCreatePageState
    extends State<RestaurantProductsCreatePage>
    with SingleTickerProviderStateMixin {
  RestaurantProductsCreateController _con =
      new RestaurantProductsCreateController();
  TabController? _widgetSelection;
  @override
  void initState() {
    super.initState();
    _widgetSelection = new TabController(length: 2, vsync: this);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          SizedBox(
            height: 20,
          ),
          Text(
            'CREAR PUBLICACIÓN',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(height: 30),
          Container(
            height: MediaQuery.of(context).size.height * 0.26,
            width: MediaQuery.of(context).size.width * 1,
            child: GestureDetector(
              onTap: () {
                _con.showAlertDialog(1);
              },
              // ignore: unnecessary_null_comparison
              child: _con.imageFile1 != null
                  ? Card(
                      elevation: 3.0,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.26,
                        width: MediaQuery.of(context).size.width * 1,
                        child: Image.file(
                          _con.imageFile1!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Card(
                      elevation: 3.0,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.26,
                        width: MediaQuery.of(context).size.width * 1,
                        child: Image(
                          image: AssetImage('assets/iconApp/fly.png'),
                        ),
                      ),
                    ),
            ),
          ),
          _typeSelection(),
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: TabBarView(controller: _widgetSelection, children: [
              ListView(
                children: [
                  _textFieldName(),
                  _textFieldDescription(),
                  _textFieldPrice(),
                  _buttonCreate(),
                ],
              ),
              ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Por cada venta COMPLETA en el establecimiento que recomiende, recibirá una RUSHCOIN la cual puede ser canjeada en:',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('- Descuento en pedidos',
                            style: TextStyle(color: Colors.white)),
                        SizedBox(
                          height: 5,
                        ),
                        Text('- Propina para motorizados',
                            style: TextStyle(color: Colors.white)),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                            '- Donacion a fundaciones (NOS TOMAMOS LAS COSAS ENSERIO; Si realiza una donación, si le enviará un video de comprobación de su donación.)',
                            style: TextStyle(color: Colors.white)),
                        Text(
                            'REQUISITO: Haber realizado al menos un pedido en el establecimiento que va a recomendar',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  _textFieldName(),
                  _textFieldDescription(),
                  _textFieldEstablecimiento(),
                  _buttonCreateRecommendation()
                ],
              )
            ]),
          ),
        ],
      ),
    );
  }

  Widget _typeSelection() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: TabBar(controller: _widgetSelection, tabs: [
        Container(
          child: Text('Publicación'),
        ),
        Container(
          child: Text('Recomendación'),
        ),
      ]),
    );
  }

  Widget _textFieldName() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: TextField(
        controller: _con.nameController,
        maxLines: 1,
        maxLength: 60,
        decoration: InputDecoration(
            hintText: 'Título',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(color: MyColors.primaryColorDark),
            suffixIcon: Icon(
              Icons.local_pizza,
              color: Colors.deepOrange,
            )),
      ),
    );
  }

  Widget _textFieldPrice() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: TextField(
        controller: _con.priceController,
        keyboardType: TextInputType.phone,
        maxLines: 1,
        decoration: InputDecoration(
            hintText: 'Precio',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(color: MyColors.primaryColorDark),
            suffixIcon: Icon(
              Icons.monetization_on,
              color: Colors.deepOrange,
            )),
      ),
    );
  }

  Widget _textFieldDescription() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: TextField(
        controller: _con.descriptionController,
        maxLines: 3,
        maxLength: 80,
        decoration: InputDecoration(
          hintText: 'Descripcion',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
          hintStyle: TextStyle(color: MyColors.primaryColorDark),
          suffixIcon: Icon(
            Icons.description,
            color: MyColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _textFieldEstablecimiento() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: TextField(
        controller: _con.descriptionController,
        maxLines: 3,
        maxLength: 80,
        decoration: InputDecoration(
          hintText: 'Establecimiento',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
          hintStyle: TextStyle(color: MyColors.primaryColorDark),
          suffixIcon: Icon(
            Icons.description,
            color: MyColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buttonCreate() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      child: ElevatedButton(
        onPressed: _con.createProduct,
        child: Text('Publicar'),
        style: ElevatedButton.styleFrom(
            // ignore: deprecated_member_use
            primary: MyColors.primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: EdgeInsets.symmetric(vertical: 15)),
      ),
    );
  }

  Widget _buttonCreateRecommendation() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      child: ElevatedButton(
        onPressed: _con.createProduct,
        child: Text('Recomendar'),
        style: ElevatedButton.styleFrom(
            // ignore: deprecated_member_use
            primary: MyColors.primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: EdgeInsets.symmetric(vertical: 15)),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
