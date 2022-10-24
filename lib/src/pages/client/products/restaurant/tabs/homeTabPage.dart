import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/pages/client/orders/list/client_orders_list_page.dart';
import 'package:jcn_delivery/src/pages/client/products/restaurant/restaurants_list_controller.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/chat_page.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:jcn_delivery/src/widgets/cards_view.dart';
import 'package:jcn_delivery/src/widgets/publications_card_widget.dart';
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
    return Container(
      color: Color.fromARGB(255, 39, 39, 39),
      child: FadeIn(
        child: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [videoWidget(), homeWidget(context), ordersWidget()],
        ),
      ),
    );
  }

  ordersWidget() {
    return FadeInDown(child: ClientOrdersListPage());
  }

  Widget videoWidget() {
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
  }

  SafeArea homeWidget(context) {
    ScrollController scrollController = ScrollController();
    return SafeArea(
        child: Obx((() => Container(
              color: Color.fromARGB(255, 41, 41, 41),
              height: MediaQuery.of(context).size.height * 1,
              child: ListView(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.1,
                    child: ListView(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      children: [
                        filterRestaurants('Todos'),
                        filterRestaurants('Populares'),
                        filterRestaurants('Huequitas'),
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
                              color: Color.fromARGB(255, 41, 41, 41),
                              height: MediaQuery.of(context).size.height * 0.2,
                              width: double.infinity,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      _con.generalActions.restaurants.length,
                                  itemBuilder: (_, index) {
                                    return _con.generalActions
                                            .restaurants[index].description!
                                            .contains(generalActions
                                                .filterRestaurants)
                                        ? FadeInRight(
                                            delay: Duration(milliseconds: 100),
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
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.1,
                    child: ListView(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      children: [
                        filterPublications('Recomendados'),
                        filterPublications('Conciéntete'),
                        filterPublications('Dos personas'),
                        filterPublications('Familiares'),
                        filterPublications('Kit Asados'),
                        filterPublications('Kit Licores')
                      ],
                    ),
                  ),
                  _con.generalActions.publications.length != 0
                      ? Container(
                          color: Color.fromARGB(255, 41, 41, 41),
                          child: FadeInUp(
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    _con.generalActions.publications.length,
                                itemBuilder: (context, index) {
                                  return _con.generalActions.publications[index]
                                          .subtitle!
                                          .contains(
                                              generalActions.filterPublications)
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
            ))));
  }

  TextButton filterRestaurants(String key) {
    return TextButton(
        onPressed: () {
          _con.filterRestaurants(key);
        },
        child: Text(
          key,
          style: TextStyle(
              color: generalActions.filterRestaurants.value == key
                  ? Colors.white
                  : Color.fromARGB(255, 194, 194, 194),
              fontFamily: generalActions.filterRestaurants.value == key
                  ? 'MontserratSemiBold'
                  : 'MontserratRegular'),
        ));
  }

  TextButton filterPublications(String key) {
    return TextButton(
        onPressed: () {
          _con.filterPublications(key);
        },
        child: Text(
          key,
          style: TextStyle(
              color: generalActions.filterPublications.value == key
                  ? Colors.white
                  : Color.fromARGB(255, 194, 194, 194),
              fontFamily: generalActions.filterPublications.value == key
                  ? 'MontserratSemiBold'
                  : 'MontserratRegular'),
        ));
  }
}
