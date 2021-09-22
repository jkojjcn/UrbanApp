import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/models/category.dart';
import 'package:jcn_delivery/src/models/product.dart';

import 'package:jcn_delivery/src/pages/client/products/list/client_products_list_page.dart';
import 'package:jcn_delivery/src/pages/client/products/restaurant/restaurants_list_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';

class RestaurantsListPage extends StatefulWidget {
  LatLng latLngClient;

  RestaurantsListPage({Key key, this.latLngClient}) : super(key: key);

  @override
  _RestaurantsListPageState createState() => _RestaurantsListPageState();
}

class _RestaurantsListPageState extends State<RestaurantsListPage> {
  RestaurantsListController _con = new RestaurantsListController();
  bool _searchVisible = true;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  String distanciaPrecio;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _con.categories?.length,
      child: Scaffold(
        key: _con.key,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(145),
          child: AppBar(
            title: BounceInDown(
              delay: Duration(seconds: 1),
              child: Center(
                child: Text(
                  '           MIKUNA',
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontFamily: 'MontserratSemiBold'),
                ),
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            actions: [_shoppingBag()],
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  _menuDrawer(),
                  SizedBox(
                    height: 10,
                  ),
                  Visibility(
                      visible: _searchVisible ?? true,
                      child: _textFieldSearch()),
                ],
              ),
            ),
            bottom: TabBar(
              indicatorColor: MyColors.primaryColor,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey[400],
              isScrollable: true,
              tabs: List<Widget>.generate(_con.categories.length, (index) {
                return FadeIn(
                  child: Tab(
                    child: Text(
                      _con.categories[index].name ?? '',
                      style: TextStyle(
                          fontSize: 12, fontFamily: 'MontserratMedium'),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        drawer: _drawer(),
        backgroundColor: Colors.white,
        body: FadeIn(
          child: TabBarView(
            children: _con.categories.map((Category category) {
              return FutureBuilder(
                  future: _con.getProducts(category.id, _con.productName),
                  builder: (context, AsyncSnapshot<List<Product>> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length > 0) {
                        snapshot.data.forEach((element) {
                          double _distance = Geolocator.distanceBetween(
                              element.lat,
                              element.lng,
                              _con.currentAddress.lat,
                              _con.currentAddress.lng);
                          element.price = _distance;
                        });
                        snapshot.data
                            .sort((a, b) => a.price.compareTo(b.price));
                        return FadeIn(
                          delay: Duration(milliseconds: 300),
                          child: GridView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1, childAspectRatio: 1.8),
                              itemCount: snapshot.data?.length ?? 0,
                              itemBuilder: (_, index) {
                                return _cardProduct(snapshot.data[index]);
                              }),
                        );
                      } else {
                        return FadeIn(
                            delay: Duration(milliseconds: 300),
                            child: NoDataWidget(text: 'No hay productos'));
                      }
                    } else {
                      return FadeIn(
                          delay: Duration(milliseconds: 300),
                          child: NoDataWidget(text: 'No hay productos'));
                    }
                  });
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _cardProduct(Product product) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ClientProductsListPage(
                        restaurantId: product.id,
                        restaurant: product,
                      )));
        },
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
          ),
          child: Stack(
            children: <Widget>[
              Container(
                  // height: 100,
                  width: MediaQuery.of(context).size.width * 0.98,
                  decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(20),
                      color: Colors.grey,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 5,
                            offset: Offset(4, 10))
                      ]),
                  //s color: Colors.black,
                  child: Image.network(
                    product.image1,
                    fit: BoxFit.fill,
                  )),
              product.name != "Servicio Delivery"
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          //  _iconDisponibilidad(),
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              width: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                //  borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Icon(
                                      Icons.delivery_dining,
                                      color: MyColors.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  _con.restaurantDistance(product.price)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              Positioned(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                      //    borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.025),
                      Colors.black.withOpacity(0.015),
                      Colors.black.withOpacity(0.010),
                      Colors.black.withOpacity(0.005),
                    ],
                  )),
                ),
              )),
              Positioned(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: RichText(
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(children: [
                            TextSpan(
                                text: "${product.name} \n",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: "${product?.description ?? ''} \n",
                                style: TextStyle(fontSize: 13)),
                          ], style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Icon(
                                Icons.timer,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Text(
                                '45',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ));
  }

  Widget _shoppingBag() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(right: 15, top: 13),
            child: Image.asset('assets/iconApp/1.png', width: 30, height: 30),
          ),
        ],
      ),
    );
  }

  Widget _textFieldSearch() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 40,
        child: TextField(
          onChanged: _con.onChangeText,
          decoration: InputDecoration(
              hintText: 'Busca restaurantes o comida',
              suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[700])),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300])),
              contentPadding: EdgeInsets.all(15)),
        ),
      ),
    );
  }

  Widget _menuDrawer() {
    return GestureDetector(
      onTap: _con.openDrawer,
      child: Container(
          margin: EdgeInsets.only(left: 15, top: 0),
          alignment: Alignment.centerLeft,
          child: Stack(
            children: [
              GestureDetector(
                onTap: _con.openDrawer,
                child: Container(
                  child:
                      Icon(Icons.settings, size: 25, color: Colors.grey[500]),
                  width: 25,
                  height: 25,
                ),
              )
            ],
          )),
    );
  }

  Widget _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: BoxDecoration(color: MyColors.primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_con.user?.name ?? ''} ${_con.user?.lastname ?? ''}',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  Text(
                    _con.user?.email ?? '',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[200],
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                    maxLines: 1,
                  ),
                  Text(
                    _con.user?.phone ?? '',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[200],
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                    maxLines: 1,
                  ),
                  Container(
                    height: 60,
                    margin: EdgeInsets.only(top: 10),
                    child: FadeInImage(
                      image: _con.user?.image != null
                          ? NetworkImage(_con.user?.image)
                          : AssetImage('assets/img/no-image.png'),
                      fit: BoxFit.contain,
                      fadeInDuration: Duration(milliseconds: 50),
                      placeholder: AssetImage('assets/img/no-image.png'),
                    ),
                  )
                ],
              )),
          ListTile(
            onTap: _con.goToUpdatePage,
            title: Text('Editar perfil'),
            trailing: Icon(Icons.edit_outlined),
          ),
          ListTile(
            onTap: _con.goToOrdersList,
            title: Text('Mis pedidos'),
            trailing: Icon(Icons.shopping_cart_outlined),
          ),
          _con.user != null
              ? _con.user.roles.length > 1
                  ? ListTile(
                      onTap: _con.goToRoles,
                      title: Text('Seleccionar rol'),
                      trailing: Icon(Icons.person_outline),
                    )
                  : Container()
              : Container(),
          ListTile(
            onTap: _con.logout,
            title: Text('Cerrar sesion'),
            trailing: Icon(Icons.power_settings_new),
          ),
        ],
      ),
    );
  }

  void refresh() {
    setState(() {}); // CTRL + S
  }
}
