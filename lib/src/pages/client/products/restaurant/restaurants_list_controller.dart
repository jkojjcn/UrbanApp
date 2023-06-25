import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/models/address.dart';
import 'package:jcn_delivery/src/models/category.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/publications.dart';
import 'package:jcn_delivery/src/models/restaurant.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/client/products/detail/client_products_detail_page.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/chat_controller.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/chats/chats_controller.dart';
import 'package:jcn_delivery/src/provider/categories_restaurants_provider.dart';
import 'package:jcn_delivery/src/provider/chats_provider.dart';
import 'package:jcn_delivery/src/provider/message_provider.dart';
import 'package:jcn_delivery/src/provider/publications_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/provider/restaurants_provider.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantsListController {
  late BuildContext context;

  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  User user = User.fromJson(GetStorage().read('user'));
  Address currentAddress =
      Address.fromJson(jsonDecode(GetStorage().read('currentAddress')) ?? {});

  RestaurantsProvider _restaurantsProvider = new RestaurantsProvider();
  PublicationsProvider _publicationsProvider = new PublicationsProvider();
  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();
  ChatProvider chatProvider = ChatProvider();
  MessageProvider messageProvider = new MessageProvider();

  ChatMainController chatController = Get.put(ChatMainController());
  ChatsController chatsControllers = Get.put(ChatsController());
  GeneralActions generalActions = Get.put(GeneralActions());
  GetStorage storage = GetStorage();

  List<Publications> publicationsListEmpy = [];
  List<Restaurant> restaurantsListEmpy = [];
  double distanciaCliente = 0.0;

  Future init(
    BuildContext context,
  ) async {
    this.context = context;
    _restaurantsProvider.init(context, user);
    _publicationsProvider.init(context, user);
    getPublications();
    getProducts('1');
    saveToken();
    chatsControllers.listenMessage();
  }

  void saveToken() {
    if (user.id != null) {
      pushNotificationsProvider.saveToken(user.id!);
    } else {}
  }

  Future<double> distanceRestaurant(LatLng distance) async {
    distanciaCliente = Geolocator.distanceBetween(distance.latitude,
        distance.longitude, currentAddress.lat!, currentAddress.lng!);
    // update();
    return distanciaCliente;
  }

  void filterRestaurants(String key) {
    generalActions.filterRestaurants.value = key;
  }

  void filterPublications(String key) {
    generalActions.filterPublications.value = key;
  }

  void getProducts(String idCategory) async {
    restaurantsListEmpy.clear();
    generalActions.restaurants.clear();
    restaurantsListEmpy = await _restaurantsProvider.getByCategory(idCategory);
    restaurantsListEmpy.forEach((element) async {
      double distanceBetwen = 0;
      distanceBetwen =
          await distanceRestaurant(LatLng(element.lat!, element.lng!));
      if ((distanceBetwen / 1000) < 15) {
        if (!generalActions.restaurants.contains(element)) {
          double floatDistance = 0;
          floatDistance = distanceBetwen / 1000;
          if (element.description!.contains('04')) {
            element.price = await generalActions
                .distancePriceSantaElena(floatDistance.toInt());
            generalActions.restaurants.add(element);
          } else if (element.description!.contains('07')) {
            element.price =
                await generalActions.distancePriceCuenca(floatDistance.toInt());
            generalActions.restaurants.add(element);
            generalActions.restaurants
                .sort((a, b) => a.price!.compareTo(b.price!));
          } else if (element.description!.contains('000')) {
            generalActions.restaurants.add(element);
            generalActions.restaurants
                .sort((a, b) => a.price!.compareTo(b.price!));
            Get.snackbar('Carrera gratis en', '${element.name}',
                backgroundColor: Colors.white);
          }
        }
      }
    });
  }

  void getPublications() async {
    publicationsListEmpy.clear();
    generalActions.publications.clear();
    publicationsListEmpy = await _publicationsProvider.getAll();
    publicationsListEmpy.forEach((element) async {
      double distanceBetwen = 0;
      distanceBetwen = await distanceRestaurant(
          LatLng(element.restaurant!.lat!, element.restaurant!.lng!));
      if ((distanceBetwen / 1000) < 15) {
        if (!generalActions.publications.contains(element)) {
          double floatDistance = 0;
          floatDistance = distanceBetwen / 1000;
          if (element.restaurant!.description!.contains('04')) {
            element.restaurant!.price = await generalActions
                .distancePriceSantaElena(floatDistance.toInt());
            generalActions.publications.add(element);
          } else if (element.restaurant!.description!.contains('07')) {
            element.restaurant!.price =
                await generalActions.distancePriceCuenca(floatDistance.toInt());
            generalActions.publications.add(element);
          } else if (element.restaurant!.description!.contains('000')) {
            generalActions.publications.add(element);
          }
        }
      }
    });
  }

  void openBottomSheet(Product product, Product restaurant) {
    showMaterialModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => ClientProductsDetailPage(
              product: product,
            ));
  }

  void logout() async {
    Get.offNamedUntil('/login', (route) => false);
    GetStorage().remove('user');
  }

  void openDrawer() {
    key.currentState!.openDrawer();
  }

  void goToUpdatePage() {
    Get.toNamed('/client/update');
  }

  void goToOrdersList() {
    Get.toNamed('/client/orders/list');
  }

  void goToAddressList() {
    Get.offNamed('/client/address/list');
  }

  void goToOrderCreatePage() {
    Get.toNamed('/client/orders/create');
  }

  void goToRoles() {
    Get.offNamedUntil('/roles', (route) => false);
  }

  openTelf(String number) async {
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

  void openAppInfo() {
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
                                style: TextStyle(fontSize: 13),
                              ),
                              actions: [
                                Column(
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          openTelf('+593998041037');
                                        },
                                        child: Text('Llamada')),
                                    TextButton(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                                  text: '+593998041037'))
                                              .then((value) {
                                            //only if ->
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Texto Copiado'); // -> show a notification
                                          });
                                        },
                                        child: Text('Copiar número'))
                                  ],
                                )
                              ]);
                        });
                  },
                  child: Text('Trabaja con nosotros')),
            ],
          );
        });
  }
}
