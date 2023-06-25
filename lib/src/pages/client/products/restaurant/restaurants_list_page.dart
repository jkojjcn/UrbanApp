import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:jcn_delivery/src/pages/client/products/restaurant/restaurants_list_controller.dart';
import 'package:jcn_delivery/src/pages/client/products/restaurant/tabs/homeTabPage.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';

// ignore: must_be_immutable
class RestaurantsListPage extends StatefulWidget {
  RestaurantsListPage({
    Key? key,
  }) : super(key: key);

  @override
  _RestaurantsListPageState createState() => _RestaurantsListPageState();
}

class _RestaurantsListPageState extends State<RestaurantsListPage>
    with SingleTickerProviderStateMixin {
  RestaurantsListController _con = new RestaurantsListController();
  TabController? _tabController;
  GeneralActions generalActions = Get.find();

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 1);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
    });
    Fluttertoast.showToast(
        msg: 'Desliza para ver más', gravity: ToastGravity.CENTER);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _con.key,
        backgroundColor: Colors.green,
        drawer: drawer(),
        appBar: _tabController?.index == 1 ? appBar(context) : null,
        body: Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height * 1,
            child: Stack(
              children: [
                TabViewWidget(tabController: _tabController!, con: _con),
                //  tabViewBar(context),
              ],
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [
                Colors.transparent,
                Color.fromARGB(255, 68, 87, 96),
                Color.fromARGB(255, 68, 87, 96),
                Color.fromARGB(255, 68, 87, 96),
                Colors.transparent,
              ])),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: 'userButtonFloat',
                mini: true,
                backgroundColor: _tabController?.index == 0
                    ? Color.fromARGB(255, 255, 255, 255)
                    : Color.fromARGB(255, 167, 167, 167),
                onPressed: () {
                  setState(() {
                    _tabController?.index = 0;
                  });
                },
                child: iconFadeIn(Icons.person),
              ),
              /*   FloatingActionButton(
                heroTag: 'videoButtonFloat',
                mini: true,
                backgroundColor: _tabController?.index == 0
                    ? Color.fromARGB(255, 255, 255, 255)
                    : Color.fromARGB(255, 167, 167, 167),
                onPressed: () {
                  setState(() {
                    _tabController?.index = 0;
                  });
                },
                child: iconFadeIn(Icons.play_arrow_rounded),
              ),*/
              FloatingActionButton(
                  heroTag: 'homeButtonFloat',
                  mini: true,
                  backgroundColor: _tabController?.index == 1
                      ? Color.fromARGB(255, 255, 255, 255)
                      : Color.fromARGB(255, 167, 167, 167),
                  child: iconFadeIn(Icons.home_filled),
                  onPressed: () {
                    setState(() {
                      _tabController?.index = 1;
                    });
                  }),
              FloatingActionButton(
                heroTag: 'shoppingButtonFloat',
                mini: true,
                backgroundColor: _tabController?.index == 2
                    ? Color.fromARGB(255, 255, 255, 255)
                    : Color.fromARGB(255, 167, 167, 167),
                onPressed: () {
                  setState(() {
                    _tabController?.index = 2;
                  });
                },
                child: iconFadeIn(Icons.shopping_bag),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Align tabViewBar(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 32, 32, 32),
          ),
          height: MediaQuery.of(context).size.height * 0.05,
          width: MediaQuery.of(context).size.width * 1,
          alignment: Alignment.bottomCenter,
          child: TabBar(
            indicatorColor: Colors.deepOrange,
            labelColor: Colors.deepOrange,
            unselectedLabelColor: Colors.white,
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconFadeIn(Icons.play_arrow_rounded),
                  Text(
                    'Descubrir',
                    style: TextStyle(color: Colors.black),
                  )
                ],
              ),
              FadeIn(
                child: Container(
                  //  margin: EdgeInsets.only(bottom: 15),
                  width: MediaQuery.of(context).size.width * 0.25,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      'assets/urban/logoTransparentWhite.png',
                    ),
                  )),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconFadeIn(Icons.shopping_bag),
                  Text(
                    'Mis pedidos',
                    style: TextStyle(color: Colors.black),
                  )
                ],
              ),
            ],
          )),
    );
  }

  FadeIn iconFadeIn(IconData icon) {
    return FadeIn(
        child: Icon(
      icon,
      color: Colors.black,
    ));
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
        backgroundColor: Color.fromARGB(255, 32, 32, 32),
        title: appBarTitleAddress(context),
        centerTitle: true,
        actions: [
          messagesButton(),
        ],
        leading: drawerButton());
  }

  FadeInDown drawerButton() {
    return FadeInDown(
      duration: Duration(seconds: 2),
      delay: Duration(milliseconds: 300),
      child: IconButton(
        icon: Icon(
          Icons.list,
          color: Colors.white,
        ),
        onPressed: () {
          _con.openDrawer();
        },
      ),
    );
  }

  FadeInDown messagesButton() {
    return FadeInDown(
      duration: Duration(seconds: 2),
      delay: Duration(milliseconds: 600),
      child: FloatingActionButton(
          child: Stack(
            children: [
              Center(
                  child: Icon(
                Icons.notifications,
                color: Colors.white,
              )),
              generalActions.chats.length != 0
                  ? Obx(() {
                      return chatCountIcon();
                    })
                  : Container(),
            ],
          ),
          heroTag: "messageButton",
          mini: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () {
            Get.toNamed('/chatPage');
          }),
    );
  }

  FadeInDown appBarTitleAddress(BuildContext context) {
    return FadeInDown(
      child: GestureDetector(
        onTap: _con.goToAddressList,
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 109, 109, 109),
              borderRadius: BorderRadius.circular(10)),
          width: MediaQuery.of(context).size.width * 0.5,
          child: Center(
            child: Text(
              _con.currentAddress.address ?? '',
              overflow: TextOverflow.clip,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget chatCountIcon() {
    return generalActions.chats.last.unreadMessage != 0
        ? Align(
            alignment: Alignment.topRight,
            child: Container(
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
            ),
          )
        : Container();
  }

  Text textUserDrawer(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 12,
          overflow: TextOverflow.ellipsis,
          color: Colors.white,
          fontWeight: FontWeight.bold),
      maxLines: 1,
    );
  }

  Widget drawer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Drawer(
        backgroundColor: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                _con.goToUpdatePage();
              },
              child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.black),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black,
                        backgroundImage:
                            AssetImage('assets/urban/logoTransparent.png'),
                      ),
                      Column(
                        children: [
                          textUserDrawer(
                              '${_con.user.name ?? ''} ${_con.user.lastname ?? ''}'),
                          textUserDrawer(_con.user.email ?? ''),
                          textUserDrawer(_con.user.phone ?? '')
                        ],
                      ),
                    ],
                  )),
            ),
            Column(
              children: [
                Column(
                  children: [
                    drawerAction(
                        'Cambiar Ubicación', Icons.place, _con.goToAddressList),
                    drawerAction('Ver Pedidos', Icons.shopping_bag_outlined,
                        _con.goToOrdersList),
                    _con.user.roles?.length != 1
                        ? drawerAction(
                            'Soy Corcel Team',
                            Icons.swap_horizontal_circle_rounded,
                            _con.goToRoles)
                        : Container(),
                    drawerAction('Cerrar sesión', Icons.logout, _con.logout),
                    Divider(),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                FadeInLeft(
                    delay: Duration(milliseconds: 300),
                    duration: Duration(milliseconds: 800),
                    child: ListTile(
                      title: Text(
                        "Información",
                        style: TextStyle(color: Colors.white),
                      ),
                      leading: Icon(
                        Icons.info,
                        color: Colors.white,
                      ),
                      onTap: _con.openAppInfo,
                    )),
              ],
            ),
            SizedBox()
          ],
        ),
      ),
    );
  }

  FadeInLeft drawerAction(String title, IconData icon, onTap()) {
    return FadeInLeft(
      delay: Duration(milliseconds: 300),
      duration: Duration(milliseconds: 300),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        leading: Icon(
          icon,
          color: Colors.deepOrange,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void refresh() {
    setState(() {}); // CTRL + S
  }
}
