import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/models/address.dart';
import 'package:jcn_delivery/src/models/category.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/products/detail/client_products_detail_page.dart';
import 'package:jcn_delivery/src/pages/client/products/list/client_products_list_controller.dart';
import 'package:jcn_delivery/src/pages/client/products/list/client_products_list_page.dart';
import 'package:jcn_delivery/src/pages/client/products/restaurant/restaurants_list_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';
import 'package:transparent_image/transparent_image.dart';

class RestaurantsListPage extends StatefulWidget {
  LatLng latLngClient;

  RestaurantsListPage({Key key, this.latLngClient}) : super(key: key);

  @override
  _RestaurantsListPageState createState() => _RestaurantsListPageState();
}

class _RestaurantsListPageState extends State<RestaurantsListPage> {
  RestaurantsListController _con = new RestaurantsListController();
  // Address a = Address.fromJson(await _sharedPref.read('address') ?? {});
  bool _searchVisible = true;

  @override
  void initState() {
    // TODO: implement initState
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
          preferredSize: Size.fromHeight(150),
          child: AppBar(
            title: Center(
              child: Text(
                '           MIKUNA DELIVERY',
                style: TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            actions: [_shoppingBag()],
            flexibleSpace: Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.grey, blurRadius: 10, offset: Offset(4, 5))
              ]
                  //borderRadius: BorderRadius.circular(30)
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
                      child: _textFieldSearch())

                  //   SizedBox(height: 0),
                ],
              ),
            ),
            bottom: TabBar(
              indicatorColor: MyColors.primaryColor,
              labelColor: Colors.orange[300],
              unselectedLabelColor: Colors.grey[400],
              isScrollable: true,
              tabs: List<Widget>.generate(_con.categories.length, (index) {
                return Tab(
                  child: Text(_con.categories[index].name ?? ''),
                );
              }),
            ),
          ),
        ),
        drawer: _drawer(),
        backgroundColor: Colors.white,
        body: TabBarView(
          children: _con.categories.map((Category category) {
            return FutureBuilder(
                future: _con.getProducts(category.id, _con.productName),
                builder: (context, AsyncSnapshot<List<Product>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length > 0) {
                      // List<Product> _listaOrdenada = [];
                      snapshot.data.forEach((element) {
                        double _distance = Geolocator.distanceBetween(
                            element.lat,
                            element.lng,
                            _con.currentAddress.lat,
                            _con.currentAddress.lng);
                        element.price = _distance;
                      });
                      snapshot.data.sort((a, b) => a.price.compareTo(b.price));
                      return GridView.builder(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1, childAspectRatio: 1.8),
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (_, index) {
                            return _cardProduct(snapshot.data[index]);
                          });
                    } else {
                      return NoDataWidget(text: 'No hay productos');
                    }
                  } else {
                    return NoDataWidget(text: 'No hay productos');
                  }
                });
          }).toList(),
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

          //  _con.openBottomSheet(product);
        },
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
          ),
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 10,
                          offset: Offset(0, 10))
                    ]),
                //s color: Colors.black,
                child: _backgroundImage(product.image1),
              ),
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
                                borderRadius: BorderRadius.circular(5),
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
                                  _restaurantDistance(product.price)
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
                      borderRadius: BorderRadius.circular(20),
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

  Widget _restaurantDistance(_distanceRC) {
    if (_distanceRC / 1000 <= 2) {
      return Text('0.99');
    } else if ((_distanceRC / 1000 > 2) && (_distanceRC / 1000 <= 3)) {
      return Text('1.25');
    } else if ((_distanceRC / 1000 > 3) && (_distanceRC / 1000 <= 4)) {
      return Text('1.49');
    } else if ((_distanceRC / 1000 > 4) && (_distanceRC / 1000 <= 5)) {
      return Text('1.75');
    } else if ((_distanceRC / 1000 > 5) && (_distanceRC / 1000 <= 6)) {
      return Text('1.99');
    } else if ((_distanceRC / 1000 > 6) && (_distanceRC / 1000 <= 7)) {
      return Text('2.25');
    } else if ((_distanceRC / 1000 > 7) && (_distanceRC / 1000 <= 8)) {
      return Text('2.49');
    } else if ((_distanceRC / 1000 > 8) && (_distanceRC / 1000 <= 9)) {
      return Text('2.75');
    } else if ((_distanceRC / 1000 > 9) && (_distanceRC / 1000 <= 10)) {
      return Text('2.99');
    } else if ((_distanceRC / 1000 > 10) && (_distanceRC / 1000 <= 11)) {
      return Text('3.49');
    } else if ((_distanceRC / 1000 > 11) && (_distanceRC / 1000 <= 12)) {
      return Text('3.75');
    } else if ((_distanceRC / 1000 > 12 && (_distanceRC / 1000 <= 13))) {
      return Text('3.99');
    } else if ((_distanceRC / 1000 > 13) && (_distanceRC / 1000 <= 14)) {
      return Text('4.25');
    } else if ((_distanceRC / 1000 > 14) && (_distanceRC / 1000 <= 15)) {
      return Text('4.49');
    } else if ((_distanceRC / 1000 > 15) && (_distanceRC / 1000 <= 16)) {
      return Text('4.75');
    } else if ((_distanceRC / 1000 > 16) && (_distanceRC / 1000 <= 17)) {
      return Text('4.99');
    } else {
      return Text('data');
    }
  }

  Widget _shoppingBag() {
    return GestureDetector(
      onTap: _con.goToOrderCreatePage,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(right: 15, top: 13),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: Colors.black,
            ),
          ),
          Positioned(
              right: 16,
              top: 15,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
              ))
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
              hintText: 'Buscar',
              suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
              hintStyle: TextStyle(fontSize: 17, color: Colors.grey[500]),
              enabledBorder: OutlineInputBorder(
                  //  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.orange)),
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
        margin: EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        child: Icon(
          Icons.miscellaneous_services_sharp,
          color: Colors.black,
        ),
        // child: Image.asset('assets/img/menu.png', width: 20, height: 20),
      ),
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

  Widget _backgroundImage(String image) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
          children: <Widget>[
            Center(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: image,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ));
    /*
    if (image.isEmpty || image == null) {
      
    } else {
      if (restaurant.disponibilidad == true) {
        return Padding(
          padding: const EdgeInsets.all(0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                      child: Align(
                    alignment: Alignment.center,
                    child: Container(height: 120, child: Loading()),
                  )),
                  Center(
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: restaurant.image,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              )),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                      child: Align(
                    alignment: Alignment.center,
                    child: Container(height: 120, child: Loading()),
                  )),
                  Center(
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: restaurant.image,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      height: 200.0,
                      child: Text(
                        'CERRADO',
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    ),
                  )
                ],
              )),
        );
      }
    }*/
  }

  void refresh() {
    setState(() {}); // CTRL + S
  }
}
