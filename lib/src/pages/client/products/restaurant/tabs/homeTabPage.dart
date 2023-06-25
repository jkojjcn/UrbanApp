import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/pages/client/orders/list/client_orders_list_page.dart';
import 'package:jcn_delivery/src/pages/client/products/restaurant/restaurants_list_controller.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/chat_page.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/profile/profile_page.dart';
import 'package:jcn_delivery/src/pages/restaurant/orders/list/restaurant_orders_list_page.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:jcn_delivery/src/widgets/cards_view.dart';
import 'package:jcn_delivery/src/widgets/publications_card_widget.dart';
import 'package:jcn_delivery/src/widgets/publications_top_widget.dart';
import 'package:jcn_delivery/src/widgets/video_player.dart';

class TabViewWidget extends StatelessWidget {
  TabViewWidget({
    Key? key,
    required RestaurantsListController con,
    required TabController tabController,
  })  : _con = con,
        _tabController = tabController,
        super(key: key);

  final RestaurantsListController _con;
  GeneralActions generalActions = Get.put(GeneralActions());

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Color.fromARGB(255, 0, 0, 0),
        child: FadeIn(
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [userWidget(), homeWidget(context), ordersWidget()],
          ),
        ),
      ),
    );
  }

  ordersWidget() {
    return FadeInDown(child: ClientOrdersListPage());
  }

  Widget userWidget() {
    return Obx(() {
      return PageView.builder(
        itemCount: _con.generalActions.restaurants.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, pageIndex) {
          bool likeRestaurant = false;
          return RestaurantOrdersListPage();
        },
      );
    });
  }

  /* Widget videoWidget() {
    return Obx(() {
      return PageView.builder(
        itemCount: _con.generalActions.restaurants.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, pageIndex) {
          bool likeRestaurant = false;
          return VideoPlayerWidget(
            restaurant: _con.generalActions.restaurants[pageIndex],
            interaction: likeRestaurant,
          );
        },
      );
    });
  } */

  SafeArea homeWidget(context) {
    ScrollController scrollController = ScrollController();
    return SafeArea(
        child: Obx((() => Stack(
              children: [
                Container(
                  color: Color.fromARGB(255, 32, 32, 32),
                  height: MediaQuery.of(context).size.height * 1,
                  child: ListView(
                    children: [
                      Container(
                        color: Color.fromARGB(255, 32, 32, 32),
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.02,
                              width: MediaQuery.of(context).size.width * 1,
                              color: Color.fromARGB(255, 41, 41, 41),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Row(
                              children: [
                                Text(
                                  '  Lo más pedido',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Color.fromARGB(255, 247, 247, 247),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Column(
                              children: [
                                _con.generalActions.publications.length != 0
                                    ? Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.15,
                                        width: double.infinity,
                                        child: FadeInUp(
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: _con.generalActions
                                                  .publications.length,
                                              itemBuilder: (context, index) {
                                                return _con
                                                        .generalActions
                                                        .publications[index]
                                                        .title!
                                                        .contains('TOP')
                                                    ? Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: PublicationsTopWidget(
                                                            publications: _con
                                                                    .generalActions
                                                                    .publications[
                                                                index]),
                                                      )
                                                    : Container();
                                              }),
                                        ),
                                      )
                                    : Center(
                                        child: FadeIn(
                                          delay: Duration(seconds: 3),
                                          child: Container(
                                            color: Colors.black,
                                            child: Text(
                                              'No hay promos disponibles por el momento',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.02,
                        width: MediaQuery.of(context).size.width * 1,
                        color: Color.fromARGB(255, 17, 17, 17),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Text(
                        '  Restaurantes',
                        style: TextStyle(
                          fontSize: 25,
                          color: Color.fromARGB(255, 231, 231, 231),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.1,
                        //  color: Color.fromARGB(255, 95, 95, 95),
                        child: ListView(
                          controller: scrollController,
                          scrollDirection: Axis.horizontal,
                          children: [
                            filterRestaurants('Todos'),
                            filterRestaurants('Populares'),
                            filterRestaurants('Huequitas'),
                            filterRestaurants('Pizza'),
                            filterRestaurants('Mariscos'),
                            filterRestaurants('Asados'),
                            filterRestaurants('China'),
                            filterRestaurants('Licores'),
                            filterRestaurants('Descuentos'),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          _con.generalActions.restaurants.length != 0
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  width: double.infinity,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _con
                                          .generalActions.restaurants.length,
                                      itemBuilder: (_, index) {
                                        return _con.generalActions
                                                .restaurants[index].description!
                                                .contains(generalActions
                                                    .filterRestaurants)
                                            ? FadeInRight(
                                                delay:
                                                    Duration(milliseconds: 100),
                                                child: CardsView(
                                                    product: _con.generalActions
                                                        .restaurants[index]),
                                              )
                                            : Container();
                                      }),
                                )
                              : FadeIn(
                                  delay: Duration(seconds: 3),
                                  child: Container(
                                    color: Colors.black,
                                    child: Text(
                                      'No hay restaurantes disponibles por el momento',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.02,
                        width: MediaQuery.of(context).size.width * 1,
                        color: Color.fromARGB(255, 17, 17, 17),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Text(
                        '  Recomendados',
                        style: TextStyle(
                          fontSize: 25,
                          color: Color.fromARGB(255, 238, 238, 238),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      _con.generalActions.publications.length != 0
                          ? Container(
                              color: Color.fromARGB(255, 32, 32, 32),
                              child: FadeInUp(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount:
                                        _con.generalActions.publications.length,
                                    itemBuilder: (context, index) {
                                      return !_con.generalActions
                                              .publications[index].subtitle!
                                              .contains('TOP')
                                          ? PublicationsCardWidget(
                                              publications: _con.generalActions
                                                  .publications[index])
                                          : Container();
                                    }),
                              ),
                            )
                          : Center(
                              child: FadeIn(
                                delay: Duration(seconds: 3),
                                child: Container(
                                  color: Colors.black,
                                  child: Text(
                                    'No hay promos disponibles por el momento',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
              ],
            ))));
  }

  filterRestaurants(String key) {
    return TextButton(
        onPressed: () {
          _con.filterRestaurants(key);
        },
        child: Text(
          key,
          style: TextStyle(
              color: generalActions.filterRestaurants.value == key
                  ? Color.fromARGB(255, 255, 255, 255)
                  : Color.fromARGB(255, 184, 184, 184),
              fontFamily: generalActions.filterRestaurants.value == key
                  ? 'MontserratSemiBold'
                  : 'Roboto'),
        ));
  }

  filterPublications(String key) {
    return TextButton(
        onPressed: () {
          _con.filterPublications(key);
        },
        child: Text(
          key,
          style: TextStyle(
              color: generalActions.filterPublications.value == key
                  ? Colors.deepOrange
                  : Color.fromARGB(255, 53, 53, 53),
              fontFamily: generalActions.filterPublications.value == key
                  ? 'MontserratSemiBold'
                  : 'Roboto'),
        ));
  }
}
