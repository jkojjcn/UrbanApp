import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/models/category.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/chat/chat_controller.dart';
import 'package:jcn_delivery/src/pages/chat/chat_page.dart';
import 'package:jcn_delivery/src/pages/client/products/list/client_products_list_page.dart';
import 'package:jcn_delivery/src/pages/client/products/restaurant/restaurants_list_controller.dart';
import 'package:jcn_delivery/src/widgets/cards_view.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

// ignore: must_be_immutable
class RestaurantsListPage extends StatefulWidget {
  LatLng? latLngClient;

  RestaurantsListPage({Key? key, this.latLngClient}) : super(key: key);

  @override
  _RestaurantsListPageState createState() => _RestaurantsListPageState();
}

class _RestaurantsListPageState extends State<RestaurantsListPage>
    with SingleTickerProviderStateMixin {
  RestaurantsListController _con = new RestaurantsListController();
  ChatController _chatController = new ChatController();
  bool dragablePanel = false;
  late PageController _controller;
  bool isOnPageTurning = false;
  int current = 0;
  void scrollListener() {
    if (isOnPageTurning &&
        _controller.page == _controller.page?.roundToDouble()) {
      setState(() {
        current = _controller.page!.toInt();
        isOnPageTurning = false;
      });
    } else if (!isOnPageTurning && current.toDouble() != _controller.page) {
      if ((current.toDouble() - _controller.page!).abs() > 0.1) {
        setState(() {
          isOnPageTurning = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
      _chatController.init(context, refresh);
      _controller = PageController();
      _controller.addListener(scrollListener);
    });
    Fluttertoast.showToast(
        msg: 'Desliza para ver más', gravity: ToastGravity.CENTER);
    // _refreshChat();
  }

  /* _refreshChat() {
    Future.delayed(Duration(seconds: 2), () {
      _chatController.unreadMessages.clear();
      _chatController.init(context, refresh);
      _chatController.unreadMessage();
      setState(() {});
    });
  }*/

  String? distanciaPrecio;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _con.categories.length,
      child: Scaffold(
        key: _con.key,
        drawer: drawer(),
        backgroundColor: Color.fromARGB(255, 7, 7, 7),
        body: Container(
          height: MediaQuery.of(context).size.height * 1,
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.9,
                child: FadeIn(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: _con.categories.map((Category category) {
                      if (category.name != 'AINICIO' &&
                          category.name != 'AARECOMENDACIONES') {
                        SystemChrome.setSystemUIOverlayStyle(
                            SystemUiOverlayStyle.light);
                        // if (_controller.value?.isPlaying) _controller.dispose();
                        return SafeArea(
                          child: FutureBuilder(
                              future: _con.getProducts(
                                  category.id!, _con.productName),
                              builder: (context,
                                  AsyncSnapshot<List<Product>> snapshot) {
                                //      _controller?.pause();
                                if (snapshot.hasData) {
                                  if (snapshot.data?.length != 0) {
                                    snapshot.data!.forEach((element) {
                                      double _distance =
                                          Geolocator.distanceBetween(
                                              element.lat!,
                                              element.lng!,
                                              _con.currentAddress!.lat!,
                                              _con.currentAddress!.lng!);
                                      element.price = _distance;
                                    });
                                    snapshot.data!.sort(
                                        (a, b) => a.price!.compareTo(b.price!));
                                    return FadeIn(
                                      delay: Duration(milliseconds: 300),
                                      child: Container(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        child: Stack(
                                          children: [
                                            /*    Padding(
                                      padding: const EdgeInsets.only(top: 60, left: 25, right: 25),
                                     child: _textFieldSearch(category.name!),
                                    ),*/
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 35),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    category.id != '1'
                                                        ? Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            5,
                                                                        left:
                                                                            5),
                                                                child: Row(
                                                                  children: [],
                                                                ),
                                                              ),
                                                              Container(
                                                                color: Colors
                                                                    .black,
                                                                height: 250,
                                                                width: double
                                                                    .infinity,
                                                                child: GridView
                                                                    .builder(
                                                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                            crossAxisCount:
                                                                                2,
                                                                            childAspectRatio:
                                                                                0.98),
                                                                        scrollDirection:
                                                                            Axis
                                                                                .horizontal,
                                                                        itemCount:
                                                                            snapshot.data?.length ??
                                                                                0,
                                                                        itemBuilder:
                                                                            (_, index) {
                                                                          return CardsView(
                                                                              product: snapshot.data![index]);
                                                                        }),
                                                              ),
                                                            ],
                                                          )
                                                        : Container(),
                                                    category.id == '1'
                                                        ? Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 10,
                                                                        bottom:
                                                                            15,
                                                                        left:
                                                                            5),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      'Cerca de ti',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              226,
                                                                              226,
                                                                              226)),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                height: 250,
                                                                width: double
                                                                    .infinity,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        37,
                                                                        37,
                                                                        37),
                                                                child: ListView
                                                                    .builder(
                                                                        scrollDirection:
                                                                            Axis
                                                                                .horizontal,
                                                                        itemCount:
                                                                            snapshot.data?.length ??
                                                                                0,
                                                                        itemBuilder:
                                                                            (_, index) {
                                                                          double
                                                                              mil =
                                                                              12000;

                                                                          if (snapshot.data![index].price! <
                                                                              mil) {
                                                                            return CardsView(product: snapshot.data![index]);
                                                                          } else {
                                                                            return Container();
                                                                          }
                                                                        }),
                                                              ),
                                                            ],
                                                          )
                                                        : Container(),
                                                    // ignore: unrelated_type_equality_checks
                                                    category.id == '1'
                                                        ? Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 10,
                                                                        bottom:
                                                                            15,
                                                                        left:
                                                                            5),
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      'Populares',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              226,
                                                                              226,
                                                                              226)),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        37,
                                                                        37,
                                                                        37),
                                                                height: 250,
                                                                width: double
                                                                    .infinity,
                                                                child: ListView
                                                                    .builder(
                                                                        scrollDirection:
                                                                            Axis
                                                                                .horizontal,
                                                                        itemCount:
                                                                            snapshot.data?.length ??
                                                                                0,
                                                                        itemBuilder:
                                                                            (_, index) {
                                                                          double
                                                                              mil =
                                                                              12000;
                                                                          double?
                                                                              _actualDistance =
                                                                              snapshot.data?[index].price;
                                                                          if (_actualDistance! <
                                                                              mil) {
                                                                            return snapshot.data![index].description!.contains("popular")
                                                                                ? CardsView(product: snapshot.data![index])
                                                                                : Container(
                                                                                    height: 1,
                                                                                  );
                                                                          } else {
                                                                            return Container();
                                                                          }
                                                                        }),
                                                              ),
                                                            ],
                                                          )
                                                        : Container(),
                                                    category.id == '1'
                                                        ? Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            5,
                                                                        left:
                                                                            5),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 10,
                                                                      bottom:
                                                                          15,
                                                                      left: 5),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        'Huequitas',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                226,
                                                                                226,
                                                                                226)),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                height: 250,
                                                                width: double
                                                                    .infinity,
                                                                child: ListView
                                                                    .builder(
                                                                        scrollDirection:
                                                                            Axis
                                                                                .horizontal,
                                                                        itemCount:
                                                                            snapshot.data?.length ??
                                                                                0,
                                                                        itemBuilder:
                                                                            (_, index) {
                                                                          double
                                                                              mil =
                                                                              12000;
                                                                          double?
                                                                              _actualDistance =
                                                                              snapshot.data?[index].price;
                                                                          if (_actualDistance! <
                                                                              mil) {
                                                                            return snapshot.data![index].description!.contains("huequitas")
                                                                                ? CardsView(product: snapshot.data![index])
                                                                                : Container();
                                                                          } else {
                                                                            return Container();
                                                                          }
                                                                        }),
                                                              ),
                                                            ],
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return FadeIn(
                                        delay: Duration(milliseconds: 300),
                                        child: NoDataWidget(
                                            text: 'No hay productos'));
                                  }
                                } else {
                                  return FadeIn(
                                      delay: Duration(milliseconds: 300),
                                      child: NoDataWidget(
                                          text: 'No hay productos'));
                                }
                              }),
                        );
                      } else if (category.name == 'AINICIO' &&
                          category.name != 'AARECOMENDACIONES') {
                        return FutureBuilder(
                            future: _con.getProducts('1', _con.productName),
                            builder: (context,
                                AsyncSnapshot<List<Product>> snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data?.length != null) {
                                  snapshot.data?.forEach((element) {
                                    double _distance =
                                        Geolocator.distanceBetween(
                                            element.lat!,
                                            element.lng!,
                                            _con.currentAddress!.lat!,
                                            _con.currentAddress!.lng!);
                                    element.price = _distance;
                                  });
                                  snapshot.data?.removeWhere(
                                      (element) => element.price! >= 12000);

                                  //   return VideoPlayerPage(videoUrl: snapshot.data?[0].image3?? "");

                                  return ListView.builder(
                                    controller: _controller,
                                    itemCount: snapshot.data?.length,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (context, pageIndex) {
                                      double mil = 12000;
                                      double? _actualDistance =
                                          snapshot.data?[pageIndex].price;
                                      if (_actualDistance! < mil) {
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: 20),
                                          child:
                                              _videoCard(snapshot, pageIndex),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                  );
                                } else {
                                  return FadeIn(
                                      delay: Duration(milliseconds: 300),
                                      child: NoDataWidget(
                                          text: 'No hay productos'));
                                }
                              } else {
                                return FadeIn(
                                    delay: Duration(milliseconds: 300),
                                    child:
                                        NoDataWidget(text: 'No hay productos'));
                              }
                            });
                      } else {
                        return Text('..');
                      }
                    }).toList(),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      Colors.transparent,
                      Colors.transparent.withOpacity(0.0),
                    ])),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                    icon: Icon(
                                      Icons.settings,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _con.openDrawer();
                                    }),
                              ),
                              Expanded(
                                flex: 9,
                                child: Container(
                                  // width: MediaQuery.of(context).size.width *0.9,
                                  child: TabBar(
                                    // physics: NeverScrollableScrollPhysics(),
                                    indicatorColor:
                                        Colors.white.withOpacity(0.5),
                                    labelColor: Colors.amber,
                                    unselectedLabelColor: Colors.grey[300],
                                    isScrollable: true,
                                    tabs: List<Widget>.generate(
                                        _con.categories.length, (index) {
                                      return FadeIn(
                                        child: Tab(
                                          child: _con.categories[index].name !=
                                                  'AINICIO'
                                              ? Text(
                                                  _con.categories[index].name ??
                                                      '',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontFamily:
                                                          'MontserratMedium'),
                                                )
                                              : Text(
                                                  'COMBITOS',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontFamily:
                                                          'MontserratMedium'),
                                                ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                    icon: Icon(
                                      Icons.shopping_bag_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _con.goToOrdersList();
                                    }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.messenger_outline_sharp,
                    color: Colors.white,
                  ),
                ),
                _chatController.unreadMessages.length > 0
                    ? Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: EdgeInsets.only(top: 5),
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(25)),
                          child: Center(
                              child: Text(
                            _chatController.unreadMessages.length.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    _chatController.unreadMessages.length < 10
                                        ? 10
                                        : 6,
                                fontFamily: "MontserratSemiBold"),
                          )),
                        ),
                      )
                    : Container(),
              ],
            ),
            heroTag: "messageButton",
            mini: true,
            elevation: 0,
            backgroundColor: Colors.black.withOpacity(0),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(),
                  ));
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      ),
    );
  }

  _videoCard(snapshot, index) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.57,
      width: MediaQuery.of(context).size.width * 1,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromARGB(135, 99, 99, 99),
          boxShadow: [
            BoxShadow(color: Colors.black, blurRadius: 9, offset: Offset(2, 2))
          ]),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(1),
                      ])),
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.height * 1,
                  child: ImageSlideshow(
                    children: [
                      CachedNetworkImage(
                        imageUrl: snapshot.data?[index].image1,
                        placeholder: (context, url) => Shimmer(
                            child: Container(
                          color: Colors.black,
                        )),
                        imageBuilder: (context, image) => Image(
                          image: image,
                          filterQuality: FilterQuality.none,
                          fit: BoxFit.fill,
                        ),
                      ),
                      CachedNetworkImage(
                        imageUrl: snapshot.data?[index].image2,
                        placeholder: (context, url) => Shimmer(
                            child: Container(
                          color: Colors.black,
                        )),
                        imageBuilder: (context, image) => Image(
                          image: image,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: ClientProductsListPage(
                        restaurantId: snapshot.data?[index].id,
                        restaurant: snapshot.data?[index],
                        panelState: true),
                  ),
                );
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.06,
                decoration: BoxDecoration(
                    color: Color.fromARGB(77, 41, 41, 41),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                child: FadeIn(
                  duration: Duration(seconds: 1),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.fastfood,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: CircleAvatar(
                              radius: 15,
                              backgroundImage:
                                  NetworkImage(snapshot.data[index].image3),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      child: Text(
                                        snapshot?.data[index].name ?? '..',
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 204, 204, 204),
                                            fontFamily: 'MontserratSemiBold',
                                            fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.delivery_dining,
                                      color: Colors.white70,
                                      size: 15,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white30,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 2,
                                            bottom: 2,
                                            left: 4,
                                            right: 4),
                                        child: _con.restaurantDistance(
                                            snapshot?.data[index].price),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

/////////////////////////Drawer logic
  ///
  ///
  ///

  Widget drawer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          //padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(color: Colors.amber),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.amber,
                      backgroundImage: AssetImage('assets/iconApp/logo1.png'),
                    ),
                    Column(
                      children: [
                        Text(
                          '${_con.user?.name ?? ''} ${_con.user?.lastname ?? ''}',
                          style: TextStyle(
                              fontSize: 12,
                              overflow: TextOverflow.ellipsis,
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
                    ),
                  ],
                )),
            Column(
              children: [
                Column(
                  children: [
                    FadeInLeft(
                      delay: Duration(milliseconds: 300),
                      duration: Duration(milliseconds: 300),
                      child: ListTile(
                        title: Text('Cambiar ubicación'),
                        leading: Icon(
                          Icons.place,
                          color: Colors.green,
                        ),
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, 'client/address/list');
                        },
                      ),
                    ),
                    FadeInLeft(
                      delay: Duration(milliseconds: 300),
                      duration: Duration(milliseconds: 400),
                      child: ListTile(
                        title: Text('Ver Pedidos'),
                        leading: Icon(
                          Icons.shopping_bag,
                          color: Colors.amber,
                        ),
                        onTap: _con.goToOrdersList,
                      ),
                    ),
                    FadeInLeft(
                      delay: Duration(milliseconds: 300),
                      duration: Duration(milliseconds: 500),
                      child: _con.user != null
                          ? _con.user?.roles?.length != 1
                              ? ListTile(
                                  title: Text('Cambiar Rol'),
                                  leading: Icon(
                                    Icons.swap_horizontal_circle_rounded,
                                    color: Colors.blue,
                                  ),
                                  onTap: _con.goToRoles,
                                )
                              : Container()
                          : Container(),
                    ),
                    FadeInLeft(
                        delay: Duration(milliseconds: 300),
                        duration: Duration(milliseconds: 600),
                        child: ListTile(
                          title: Text('Cerrar sesión'),
                          leading: Icon(
                            Icons.logout,
                            color: Colors.red,
                          ),
                          onTap: _con.logout,
                        )),
                    SizedBox(
                      height: 50,
                    ),
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
                      title: Text("Información"),
                      leading: Icon(
                        Icons.info,
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Acerca de nosotros'),
                                content: Text(
                                    'Somos una aplicación de pedidos a domicilio. Disponemos del mejor personal calificado para desempeñarse como repartidor/a. '),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                  title: Text('Contacto'),
                                                  content: Text(
                                                    'ESTABLECIMIENTOS: Contáctese para unirse al proyecto. (sin costo de afiliación ni mensualidades ni nada por el estilo). REPARTIDORES: Cupos disponibles.',
                                                    style:
                                                        TextStyle(fontSize: 13),
                                                  ),
                                                  actions: [
                                                    Column(
                                                      children: [
                                                        TextButton(
                                                            onPressed: () {
                                                              _con.openwhatsapp(
                                                                  '+593998041037');
                                                            },
                                                            child: Text(
                                                              'WhatsApp',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .greenAccent),
                                                            )),
                                                        TextButton(
                                                            onPressed: () {
                                                              _con.openTelf(
                                                                  '+593998041037');
                                                            },
                                                            child: Text(
                                                                'Llamada')),
                                                        TextButton(
                                                            onPressed: () {
                                                              Clipboard.setData(
                                                                      ClipboardData(
                                                                          text:
                                                                              '+593998041037'))
                                                                  .then(
                                                                      (value) {
                                                                //only if ->
                                                                Fluttertoast
                                                                    .showToast(
                                                                        msg:
                                                                            'Texto Copiado'); // -> show a notification
                                                              });
                                                            },
                                                            child: Text(
                                                                'Copiar número'))
                                                      ],
                                                    )
                                                  ]);
                                            });
                                      },
                                      child: Text('Trabaja con nosotros')),
                                ],
                              );
                            });
                      },
                    )),
              ],
            ),
            SizedBox()
          ],
        ),
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
