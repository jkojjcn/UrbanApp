import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/models/address.dart';
import 'package:jcn_delivery/src/models/category.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/client/products/detail/client_products_detail_page.dart';
import 'package:jcn_delivery/src/provider/categories_restaurants_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/provider/restaurants_provider.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class RestaurantsListController {
  BuildContext context;
  SharedPref _sharedPref = new SharedPref();
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  Function refresh;
  User user;
  CategoriesRestaurantsProvider _categoriesRestaurantsProvider =
      new CategoriesRestaurantsProvider();
  RestaurantsProvider _restaurantsProvider = new RestaurantsProvider();
  List<Category> categories = [];
  StreamController<String> streamController = StreamController();
  TextEditingController _searchController = new TextEditingController();

  Timer searchOnStoppedTyping;

  String productName = '';
  Address currentAddress;

  double distanciaCliente = 0.0;

  double _distanceBetween;

  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    currentAddress = Address.fromJson(await _sharedPref.read('address') ?? {});
    _categoriesRestaurantsProvider.init(context, user);
    _restaurantsProvider.init(context, user);

    getCategories();
    refresh();
  }

  void onChangeText(String text) {
    const duration = Duration(
        milliseconds:
            800); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      searchOnStoppedTyping.cancel();
      refresh();
    }

    searchOnStoppedTyping = new Timer(duration, () {
      productName = text;
      refresh();
      // getProducts(idCategory, text)
      print('TEXTO COMPLETO $text');
    });
  }

  Future<double> distanceRestaurant(LatLng distance) async {
    Map<String, double> restaurantes = {};

    Address a = Address.fromJson(await _sharedPref.read('address') ?? {});

    distanciaCliente = Geolocator.distanceBetween(
        distance.latitude, distance.longitude, a.lat, a.lng);
    // refresh();
    return distanciaCliente;
  }

  Future<List<Product>> getProducts(
      String idCategory, String productName) async {
    if (productName.isEmpty) {
      return await _restaurantsProvider.getByCategory(idCategory);
    } else {
      return await _restaurantsProvider.getByCategoryAndRestaurantName(
          idCategory, productName);
    }
  }

  void getCategories() async {
    categories = await _categoriesRestaurantsProvider.getAll();
    refresh();
  }

  void openBottomSheet(Product product) {
    showMaterialModalBottomSheet(
        context: context,
        builder: (context) => ClientProductsDetailPage(product: product));
  }

  void logout() {
    _sharedPref.logout(context, user.id);
  }

  void openDrawer() {
    key.currentState.openDrawer();
  }

  void goToUpdatePage() {
    Navigator.pushNamed(context, 'client/update');
  }

  void goToOrdersList() {
    Navigator.pushNamed(context, 'client/orders/list');
  }

  void goToOrderCreatePage() {
    Navigator.pushNamed(context, 'client/orders/create');
  }

  void goToRoles() {
    Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
  }


  restaurantDistance(_distanceRC) {
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
      return Icon(Icons.credit_card);
    }
  }


}
