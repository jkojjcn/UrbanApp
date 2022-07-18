import 'dart:async';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/models/address.dart';
import 'package:jcn_delivery/src/models/category.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/client/products/detail/client_products_detail_page.dart';
import 'package:jcn_delivery/src/provider/categories_restaurants_provider.dart';
import 'package:jcn_delivery/src/provider/message_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/provider/restaurants_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantsListController {
  late BuildContext context;
  SharedPref _sharedPref = new SharedPref();
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  late Function refresh;
  User? user;
  CategoriesRestaurantsProvider _categoriesRestaurantsProvider =
      new CategoriesRestaurantsProvider();
  RestaurantsProvider _restaurantsProvider = new RestaurantsProvider();
  List<Category> categories = [];
  List<Message> message = [];

  Timer? searchOnStoppedTyping;

  String productName = '';
  Address? currentAddress;

  double distanciaCliente = 0.0;

  List<Product>? selectedProducts = [];

  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();

  MessageProvider messageProvider = new MessageProvider();

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));

    currentAddress = Address.fromJson(await _sharedPref.read('address') ?? {});

    selectedProducts =
        Product.fromJsonList(await _sharedPref.read('order')).toList;

    _categoriesRestaurantsProvider.init(context, user!);
    _restaurantsProvider.init(context, user!);
    await messageProvider.init(context, user!);

    getCategories();
    // getMessages();
    refresh();
  }

  void onChangeText(String idCategory, String text) {
    const duration = Duration(
        milliseconds:
            800); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      searchOnStoppedTyping!.cancel();
      refresh();
    }

    searchOnStoppedTyping = new Timer(duration, () {
      productName = text;
      refresh();
      getProducts(idCategory, text);
      print('TEXTO COMPLETO $text');
    });
  }

  Future<double> distanceRestaurant(LatLng distance) async {
    Address a = Address.fromJson(await _sharedPref.read('address') ?? {});

    distanciaCliente = Geolocator.distanceBetween(
        distance.latitude, distance.longitude, a.lat!, a.lng!);
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
  /*  Future<List<Message>> getMessages() async {
    message = await messageProvider.getMessage(user!.id!);
    return message;
  }*/

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

  void logout() {
    _sharedPref.logout(context, user!.id!);
  }

  void openDrawer() {
    key.currentState!.openDrawer();
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
    if (_distanceRC / 1000 <= 1) {
      return Text(
        ' \$ 0.99',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
    } else if (_distanceRC / 1000 <= 2) {
      return Text(
        ' \$ 0.99 ',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
    } else if ((_distanceRC / 1000 > 2) && (_distanceRC / 1000 <= 3)) {
      return Text(
        ' \$ 1.49 ',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
    } else if ((_distanceRC / 1000 > 3) && (_distanceRC / 1000 <= 4)) {
      return Text(
        ' \$ 1.99 ',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
    } else if ((_distanceRC / 1000 > 4) && (_distanceRC / 1000 <= 5)) {
      return Text(
        ' \$ 2.49 ',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
    } else if ((_distanceRC / 1000 > 5) && (_distanceRC / 1000 <= 6)) {
      return Text(
        ' \$ 3.25 ',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
    } else if ((_distanceRC / 1000 > 6) && (_distanceRC / 1000 <= 7)) {
      return Text(
        ' \$ 3.69 ',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
    } else if ((_distanceRC / 1000 > 7) && (_distanceRC / 1000 <= 8)) {
      return Text(
        ' \$ 4.10 ',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
    } else if ((_distanceRC / 1000 > 8) && (_distanceRC / 1000 <= 9)) {
      return Text(
        ' \$ 4.49 ',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
    } else if ((_distanceRC / 1000 > 9) && (_distanceRC / 1000 <= 10)) {
      return Text(
        ' \$ 4.99 ',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
    } else if ((_distanceRC / 1000 > 10) && (_distanceRC / 1000 <= 11)) {
      return Text(
        ' \$ 5.25 ',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
    } else if ((_distanceRC / 1000 > 11) && (_distanceRC / 1000 <= 12)) {
      return Text(
        ' \$ 5.99 ',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
    } else if ((_distanceRC / 1000 > 12 && (_distanceRC / 1000 <= 13))) {
      return Text(
        ' \$ 6.25 ',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
    } else {
      return Icon(Icons.credit_card);
    }
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

  openwhatsapp(String number) async {
    var whatsapp = number;
    var whatsappURlA =
        "whatsapp://send?phone=" + "+593" + number + "&text=hello";
    var whatappURLI = "https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
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
}
