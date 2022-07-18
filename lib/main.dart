import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/pages/client/address/create/client_address_create_page.dart';
import 'package:jcn_delivery/src/pages/client/address/list/client_address_list_page.dart';
import 'package:jcn_delivery/src/pages/client/address/map/client_address_map_page.dart';
import 'package:jcn_delivery/src/pages/client/orders/create/client_orders_create_page.dart';
import 'package:jcn_delivery/src/pages/client/orders/list/client_orders_list_page.dart';
import 'package:jcn_delivery/src/pages/client/orders/map/client_orders_map_page.dart';
import 'package:jcn_delivery/src/pages/client/products/list/client_products_list_page.dart';
import 'package:jcn_delivery/src/pages/client/products/restaurant/restaurants_list_page.dart';
import 'package:jcn_delivery/src/pages/client/update/client_update_page.dart';
import 'package:jcn_delivery/src/pages/delivery/orders/list/delivery_orders_list_page.dart';
import 'package:jcn_delivery/src/pages/delivery/orders/map/delivery_orders_map_page.dart';
import 'package:jcn_delivery/src/pages/login/login_page.dart';
import 'package:jcn_delivery/src/pages/register/register_page.dart';
import 'package:jcn_delivery/src/pages/restaurant/categories/create/restaurant_categories_create_page.dart';
import 'package:jcn_delivery/src/pages/restaurant/orders/list/restaurant_orders_list_page.dart';
import 'package:jcn_delivery/src/pages/restaurant/products/create/restaurant_products_create_page.dart';
import 'package:jcn_delivery/src/pages/roles/roles_page.dart';
import 'package:jcn_delivery/src/pages/taxi/taxi_page.dart';
import 'package:jcn_delivery/src/provider/location_stream_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';

PushNotificationsProvider pushNotificationsProvider =
    new PushNotificationsProvider();

LocationService locationService = new LocationService();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  pushNotificationsProvider.initPushNotifications();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    pushNotificationsProvider.onMessageListener();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mikuna',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      initialRoute: 'login',
      routes: {
        'login': (BuildContext context) => LoginPage(),
        'register': (BuildContext context) => RegisterPage(),
        'roles': (BuildContext context) => RolesPage(),
        'client/products/list': (BuildContext context) =>
            ClientProductsListPage(),
        'client/update': (BuildContext context) => ClientUpdatePage(),
        'client/orders/create': (BuildContext context) =>
            ClientOrdersCreatePage(),
        'client/address/list': (BuildContext context) =>
            ClientAddressListPage(),
        'client/address/create': (BuildContext context) =>
            ClientAddressCreatePage(),
        'client/address/map': (BuildContext context) => ClientAddressMapPage(),
        'client/orders/list': (BuildContext context) => ClientOrdersListPage(),
        'client/orders/map': (BuildContext context) => ClientOrdersMapPage(),

        'client/restaurants': (BuildContext context) => RestaurantsListPage(),
        // client/products/list

        'restaurant/orders/list': (BuildContext context) =>
            RestaurantOrdersListPage(),
        'restaurant/categories/create': (BuildContext context) =>
            RestaurantCategoriesCreatePage(),
        'restaurant/products/create': (BuildContext context) =>
            RestaurantProductsCreatePage(),
        'delivery/orders/list': (BuildContext context) =>
            DeliveryOrdersListPage(),
        'delivery/orders/map': (BuildContext context) =>
            DeliveryOrdersMapPage(),
        'taxi/page/list': (BuildContext context) => TaxiDriverPage()
      },
      theme: ThemeData(
          fontFamily: 'MontserratRegular',
          primaryColor: Colors.deepOrange,
          appBarTheme: AppBarTheme(elevation: 0, color: Colors.black)),
    );
  }
}
