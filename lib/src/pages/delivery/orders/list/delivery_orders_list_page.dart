import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/pages/delivery/orders/list/delivery_orders_list_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/utils/relative_time_util.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:timer_builder/timer_builder.dart';

class DeliveryOrdersListPage extends StatefulWidget {
  @override
  _DeliveryOrdersListPageState createState() => _DeliveryOrdersListPageState();
}

class _DeliveryOrdersListPageState extends State<DeliveryOrdersListPage>
    with TickerProviderStateMixin {
  DeliveryOrdersListController _con = new DeliveryOrdersListController();
  TabController? _ordersTabController;

  GeneralActions generalActions = Get.put(GeneralActions());

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
      _ordersTabController = TabController(length: 3, vsync: this);
    });
  }

  final String urlRushImage =
      "https://i.ibb.co/55h301K/logo-White-Background.png";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _con.status.length,
      child: SafeArea(
        child: Scaffold(
          key: _con.key,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Color.fromARGB(255, 37, 37, 37),
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: Icon(Icons.refresh)),
            title: TabBar(
              controller: _ordersTabController,
              indicatorColor: MyColors.primaryColor,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[400],
              isScrollable: true,
              tabs: List<Widget>.generate(_con.status.length, (index) {
                return Tab(
                  child: Text(
                    _con.status[index],
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                );
              }),
            ),
          ),
          drawer: _drawer(),
          backgroundColor: Colors.black,
          body: TabBarView(
            controller: _ordersTabController,
            physics: NeverScrollableScrollPhysics(),
            children: _con.status.map((String status) {
              return TimerBuilder.periodic(
                Duration(seconds: 20),
                builder: (context) => FutureBuilder(
                    future: _con.getOrders(status),
                    builder: (context, AsyncSnapshot<List<Order>> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data?.length != 0) {
                          return PageView.builder(
                              physics: status == 'DESPACHADO'
                                  ? NeverScrollableScrollPhysics()
                                  : null,
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data?.length ?? 0,
                              itemBuilder: (_, i) {
                                return snapshot.data?[i].status == 'DESPACHADO'
                                    ? _cardOrderPostulate(snapshot.data![i])
                                    : _cardOrder(snapshot.data![i]);
                              });
                        } else {
                          return NoDataWidget(text: 'No hay ordenes');
                        }
                      } else {
                        return NoDataWidget(text: 'No hay ordenes');
                      }
                    }),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _cardOrderPostulate(Order order) {
    _con.addMarker('Establecimiento', order.restaurant!.lat!,
        order.restaurant!.lng!, 'Lugar de recogida', '', _con.homeMarker!);
    String _tiempoDeOrden =
        RelativeTimeUtil.getRelativeTime(order.timestamp ?? 0);

    return GestureDetector(
      onTap: () {
        //  _con.openBottomSheet(order);
      },
      child: Container(
        color: Color.fromARGB(255, 36, 36, 36),
        child: Card(
          color: Color.fromARGB(255, 36, 36, 36),
          elevation: 3.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Stack(
            children: [
              _googleMaps(order),
              Container(
                //   height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Orden #${order.id}',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontFamily: 'NimbusSans'),
                      ),
                    ),
                    Container(
                      color: Colors.black,
                      child: ListTile(
                        leading: order.restaurant?.image1 != null
                            ? Container(
                                width: 50,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: order.restaurant!.image1!,
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
                                ),
                              )
                            : Container(),
                        title: Text(
                          order.restaurant!.name ?? '',
                          maxLines: 2,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        subtitle: Text(
                          'Cliente: ${order.client.name ?? ''}',
                          style: TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(255, 179, 179, 179)),
                          maxLines: 2,
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '    Despachado en:',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            Text(
                              ((order.restaurantTime!) -
                                      double.parse(_tiempoDeOrden))
                                  .toStringAsFixed(0),
                              style: TextStyle(
                                  color: Colors.deepOrange, fontSize: 13),
                            ),
                            Text('Minutos',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              order.acepted != 'Aceptado'
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.1),
                        child: FloatingActionButton.extended(
                          label: Text('Aceptar'),
                          onPressed: () {
                            _con.updateOrderAcepted(order, _con.user!.id!);
                            Future.delayed(Duration(seconds: 4), () {
                              setState(() {});
                            });
                          },
                          icon: Icon(Icons.check),
                        ),
                      ),
                    )
                  : Container(),
              order.acepted != 'Aceptado'
                  ? Container()
                  : Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.1),
                        child: FloatingActionButton.extended(
                          backgroundColor: Colors.deepOrange,
                          label: Text('He llegado'),
                          onPressed: () {
                            _con.openBottomSheet(order);

                            Future.delayed(Duration(seconds: 3), () {
                              _ordersTabController!.index = 1;
                              setState(() {});
                            });
                          },
                          icon: Icon(Icons.place),
                        ),
                      ),
                    ),
              Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Text(
                      order.distance!.toStringAsFixed(2),
                      style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'MontserratSemiBold',
                          color: Colors.orange),
                    ),
                  )),
              order.tarjeta == 'Si'
                  ? Align(
                      alignment: Alignment.topRight,
                      child: Icon(Icons.credit_card))
                  : Container()
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
        zoomControlsEnabled: false,
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
                      order.distance!.toStringAsFixed(2),
                      style: TextStyle(
                          fontSize: 26,
                          fontFamily: 'MontserratSemiBold',
                          color: Colors.orange),
                    ),
                  )),
              order.tarjeta == 'Si'
                  ? Align(
                      alignment: Alignment.topRight,
                      child: Icon(Icons.credit_card))
                  : Container()
            ],
          ),
        ),
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
