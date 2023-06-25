import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/restaurant/orders/list/restaurant_orders_list_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/utils/relative_time_util.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:jcn_delivery/src/widgets/cards_view.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantOrdersListPage extends StatefulWidget {
  User? currentUser;
  RestaurantOrdersListPage({Key? key, this.currentUser}) : super(key: key);

  @override
  _RestaurantOrdersListPageState createState() =>
      _RestaurantOrdersListPageState();
}

class _RestaurantOrdersListPageState extends State<RestaurantOrdersListPage> {
  RestaurantOrdersListController _con = new RestaurantOrdersListController();
  GeneralActions generalActions = Get.find();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
    _actualizar();
  }

  _actualizar() {
    Future.delayed(Duration(seconds: 10), () {
      _con.init(context, refresh);
      _actualizar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _con.status.length,
      child: _con.user.lastname != ""
          ? Scaffold(
              key: _con.key,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(100),
                child: AppBar(
                  title: Text(
                    'Mi tienda',
                    style: TextStyle(color: Colors.red),
                  ),
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  actions: [
                    TextButton(
                        onPressed: () {
                          openTelf('0998041037');
                        },
                        child: Icon(Icons.phone)),
                    FadeInDown(
                      duration: Duration(seconds: 2),
                      delay: Duration(milliseconds: 600),
                      child: FloatingActionButton(
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.mail,
                                  color: Colors.white,
                                ),
                              ),
                              generalActions.chats.length != 0 &&
                                      generalActions.chats.length <= 0
                                  ? Obx(() {
                                      return Align(
                                        alignment: Alignment.topRight,
                                        child: chatCountIcon(),
                                      );
                                    })
                                  : Container(),
                            ],
                          ),
                          heroTag: "messageButton",
                          mini: true,
                          elevation: 0,
                          backgroundColor: Color.fromARGB(255, 73, 53, 53),
                          onPressed: () {
                            Get.toNamed('/chatPage');
                          }),
                    ),
                  ],
                  bottom: TabBar(
                    indicatorColor: MyColors.primaryColor,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey[400],
                    isScrollable: true,
                    tabs: List<Widget>.generate(_con.status.length, (index) {
                      return Tab(
                        child: Text(
                          _con.status[index] == 'PAGADO'
                              ? 'PENDIENTES'
                              : _con.status[index] == 'DESPACHADO'
                                  ? 'PREPARANDO'
                                  : _con.status[index],
                          style: TextStyle(
                              fontFamily: 'MontserratRegular', fontSize: 12),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              drawer: _drawer(),
              body: Column(
                children: [
                  _con.user.lastname != ""
                      ? Expanded(
                          flex: 1,
                          child: TabBarView(
                            children: _con.status.map((String status) {
                              return FutureBuilder(
                                  future: _con.getOrdersByRestaurant(
                                      status, _con.user.lastname!),
                                  builder: (context,
                                      AsyncSnapshot<List<Order>> snapshot) {
                                    //  print(status);
                                    if (snapshot.hasData) {
                                      if (snapshot.data?.length != null) {
                                        return ListView.builder(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 20),
                                            itemCount:
                                                snapshot.data?.length ?? 0,
                                            itemBuilder: (_, index) {
                                              return _cardOrder(
                                                  snapshot.data![index]);
                                            });
                                      } else {
                                        return NoDataWidget(
                                            text: 'No hay ordenes');
                                      }
                                    } else {
                                      return NoDataWidget(
                                          text: 'No hay ordenes');
                                    }
                                  });
                            }).toList(),
                          ),
                        )
                      : Container(),
                  Expanded(
                      flex: 1,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: double.infinity,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _con.generalActions.restaurants.length,
                            itemBuilder: (_, index) {
                              return _con.user.caja ==
                                      _con.generalActions.restaurants[index].id
                                  ? FadeInRight(
                                      delay: Duration(milliseconds: 100),
                                      child: CardsView(
                                          product: _con.generalActions
                                              .restaurants[index]),
                                    )
                                  : Container();
                            }),
                      ))
                ],
              ),
            )
          : Scaffold(
              appBar: AppBar(
                title: Text(_con.user.name ?? ""),
                actions: [
                  FloatingActionButton.extended(
                      backgroundColor: Colors.black,
                      label: Text('1'),
                      icon: Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                      ),
                      onPressed: () {}),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                      child: CircleAvatar(
                    radius: 60,
                    child: Image.asset('assets/urban/logofly.png'),
                  ))
                ],
              ),
            ),
    );
  }

  Widget chatCountIcon() {
    return generalActions.chats.last.unreadMessage != 0
        ? Container(
            height: 15,
            width: 15,
            decoration:
                BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: Center(
              child: Text(
                generalActions.chats.length > 0
                    ? generalActions.chats.last.unreadMessage.toString()
                    : '',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          )
        : Container();
  }

  Widget _cardOrder(Order order) {
    return GestureDetector(
      onTap: () {
        _con.openBottomSheet(order);
      },
      child: Container(
        height: 155,
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
                    'Orden #${order.id ?? ".."}',
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
                        'Hora: ${RelativeTimeUtil.getTipicTime(order.timestamp!)} ',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Cliente: ${order.client.name ?? ".."} ${order.client.lastname ?? ".."}',
                        style: TextStyle(fontSize: 13),
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Entregar en: ${order.address.neighborhood}',
                        style: TextStyle(fontSize: 13),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
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
                    '${_con.user.name ?? '..'} ${_con.user.lastname ?? '..'}',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  Text(
                    _con.user.email ?? "..",
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[200],
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                    maxLines: 1,
                  ),
                  Text(
                    _con.user.phone!,
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[200],
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                    maxLines: 1,
                  ),
                ],
              )),
          _con.user.name != null
              ? _con.user.roles!.length > 1
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

  openTelf(String? number) async {
    var whatsappURlA = "tel://$number";
    var whatappURLI = "tel://$number";
    if (Platform.isIOS) {
      // for iOS phone only
      // ignore: deprecated_member_use
      if (await canLaunch(whatappURLI)) {
        // ignore: deprecated_member_use
        await launch(whatappURLI, forceSafariVC: false);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    } else {
      // android , web
      // ignore: deprecated_member_use
      if (await canLaunch(whatsappURlA)) {
        // ignore: deprecated_member_use
        await launch(whatsappURlA);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    }
  }

  void refresh() {
    setState(() {}); // CTRL + S
  }
}
