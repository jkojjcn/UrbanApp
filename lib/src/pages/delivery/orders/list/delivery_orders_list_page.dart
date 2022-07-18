import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/pages/delivery/orders/list/delivery_orders_list_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';

class DeliveryOrdersListPage extends StatefulWidget {
  const DeliveryOrdersListPage({Key? key}) : super(key: key);

  @override
  _DeliveryOrdersListPageState createState() => _DeliveryOrdersListPageState();
}

class _DeliveryOrdersListPageState extends State<DeliveryOrdersListPage> {
  DeliveryOrdersListController _con = new DeliveryOrdersListController();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);

      _actualizar();
    });
  }

  bool value = false;
//  double wallet = 0.0;
  // bool walletShow = false;s

  _actualizar() {
    Future.delayed(Duration(milliseconds: 9500), () {
      _con.init(context, refresh);

      print('Actualizado');

      _actualizar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _con.status.length,
      child: Scaffold(
        key: _con.key,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            centerTitle: true,
            flexibleSpace: Column(
              children: [
                SizedBox(height: 40),
                _menuDrawer(),
              ],
            ),
            bottom: TabBar(
              indicatorColor: MyColors.primaryColor,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[400],
              isScrollable: true,
              tabs: List<Widget>.generate(_con.status.length, (index) {
                return Tab(
                  child: Text(_con.status[index]),
                );
              }),
            ),
          ),
        ),
        drawer: _drawer(),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: _con.status.map((String status) {
            return FutureBuilder(
                future: _con.getOrders(status),
                builder: (context, AsyncSnapshot<List<Order>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data?.length != 0) {
                      return PageView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (_, i) {
                            return snapshot.data?[i].status == 'DESPACHADO'
                                ? _cardOrderPostulate(snapshot.data![i])
                                : _cardOrder(snapshot.data![i]);
                          });
                      /* return ListView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (_, index) {
                            //   wallet = 0.0;

                            /*    if (snapshot?.data[index]?.status == 'ENTREGADO') {
                              snapshot?.data?.forEach((element) {
                                element.products.forEach((element) {
                                  wallet += element.price;
                                });
                              });
                            }*/
                            return snapshot.data?[index].status == 'DESPACHADO'
                                ? _cardOrderPostulate(snapshot.data![index])
                                : _cardOrder(snapshot.data![index]);
                          }); */
                    } else {
                      return NoDataWidget(text: 'No hay ordenes');
                    }
                  } else {
                    return NoDataWidget(text: 'No hay ordenes');
                  }
                });
          }).toList(),
        ),
      ),
    );
  }

  Widget _cardOrderPostulate(Order order) {
    _con.addMarker('Establecimiento', order.restaurant!.lat!,
        order.restaurant!.lng!, 'Lugar de recogida', '', _con.homeMarker!);

    return GestureDetector(
      onTap: () {
        //  _con.openBottomSheet(order);
      },
      child: Container(
        child: Card(
          elevation: 3.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Stack(
            children: [
              _googleMaps(order),
              Align(
                alignment: Alignment.center,
                child: Container(
                  //   height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 1,
                  child: Column(
                    children: [
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                            color: MyColors.primaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            )),
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            'Orden #${order.id}',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontFamily: 'NimbusSans'),
                          ),
                        ),
                      ),
                      Container(
                        //   color: Colors.orange[200].withOpacity(0.5),
                        margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                        child: Column(
                          children: [
                            Container(
                              color: Colors.orange,
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.symmetric(vertical: 5),
                              width: double.infinity,
                              child: Text(
                                order.restaurant!.name ?? '',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                'Cliente: ${order.client.name ?? ''} ${order.client.lastname ?? ''}',
                                style: TextStyle(fontSize: 13),
                                maxLines: 2,
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                'Entregar en: ${order.address.neighborhood ?? ''}',
                                style: TextStyle(fontSize: 13),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              order.acepted != 'Aceptado'
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                        child: ElevatedButton(
                          onPressed: () {
                            _con.updateOrderAcepted(order, _con.user!.id!);
                            setState(() {});
                          },
                          child: Text('ACEPTAR'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              padding: EdgeInsets.symmetric(vertical: 15)),
                        ),
                      ))
                  : Container(),
              order.acepted != 'Aceptado'
                  ? Container()
                  /* Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: FloatingActionButton(
                            heroTag: 'Rechazado',
                            backgroundColor: Colors.red,
                            mini: true,
                            onPressed: () {
                              _con.updateOrderRefuse(order);
                            },
                            child: Icon(
                              Icons.delete_outline_rounded,
                            ),
                          )))*/
                  : Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: GestureDetector(
                            onTap: () {
                              _con.openBottomSheet(order);
                            },
                            child: Container(
                                color: Colors.orange,
                                padding: EdgeInsets.all(10),
                                child: Text('He llegado',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white))),
                          ))),
              Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Text(
                      (_con.restaurantDistanceDelivery(order.distance))
                              .toString() +
                          '\$   ',
                      style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'MontserratSemiBold',
                          color: Colors.orange),
                    ),
                  )),
              Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(order.restaurant!.image1!),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _googleMaps(Order order) {
    return FadeIn(
      delay: Duration(seconds: 2),
      duration: Duration(seconds: 2),
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _con.initialPosition,
        onMapCreated: _con.onMapCreated,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        markers: Set<Marker>.of(_con.markers.values),
        //polylines: _con.polylines,
      ),
    );
  }

  Widget _cardOrder(Order order) {
    return GestureDetector(
      onTap: () {
        _con.openBottomSheet(order);
      },
      child: Container(
        height: 185,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Card(
          elevation: 3.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Stack(
            children: [
              Positioned(
                  child: Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                    color: MyColors.primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    )),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    'Orden #${order.id}',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontFamily: 'NimbusSans'),
                  ),
                ),
              )),
              Container(
                margin: EdgeInsets.only(top: 40, left: 20, right: 20),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      width: double.infinity,
                      child: Text(
                        order.restaurant!.name ?? '',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Cliente: ${order.client.name ?? ''} ${order.client.lastname ?? ''}',
                        style: TextStyle(fontSize: 13),
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Entregar en: ${order.address.neighborhood ?? ''}',
                        style: TextStyle(fontSize: 13),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      (_con.restaurantDistanceDelivery(order.distance))
                              .toString() +
                          '\$   ',
                      style: TextStyle(fontSize: 24),
                    ),
                  )),
              Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(order.restaurant!.image1!),
                    ),
                  )),
            ],
          ),
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
        child: Image.asset('assets/img/menu.png', width: 20, height: 20),
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
                      image: NetworkImage(_con.user?.image ?? ""),
                      fit: BoxFit.contain,
                      fadeInDuration: Duration(milliseconds: 50),
                      placeholder: AssetImage('assets/img/no-image.png'),
                    ),
                  )
                ],
              )),
          _con.user != null
              ? _con.user!.roles!.length != 1
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
