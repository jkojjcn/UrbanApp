import 'dart:developer';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/client/address/create/client_address_create_page.dart';
import 'package:jcn_delivery/src/pages/client/address/list/client_address_list_page.dart';
import 'package:jcn_delivery/src/pages/client/orders/create/client_orders_create_page.dart';
import 'package:jcn_delivery/src/pages/client/orders/list/client_orders_list_page.dart';
import 'package:jcn_delivery/src/pages/client/orders/map/client_orders_map_page.dart';
import 'package:jcn_delivery/src/pages/client/products/list/client_products_list_page.dart';
import 'package:jcn_delivery/src/pages/client/products/restaurant/restaurants_list_page.dart';
import 'package:jcn_delivery/src/pages/delivery/orders/list/delivery_orders_list_page.dart';
import 'package:jcn_delivery/src/pages/delivery/orders/map/delivery_orders_map_page.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/chat_page.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/chats/chats_page.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/messages/messages_page.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/profile/edit/profile_edit.dart';
import 'package:jcn_delivery/src/pages/login/login_page.dart';
import 'package:jcn_delivery/src/pages/register/register_page.dart';
import 'package:jcn_delivery/src/pages/restaurant/categories/create/restaurant_categories_create_page.dart';
import 'package:jcn_delivery/src/pages/restaurant/orders/list/restaurant_orders_list_page.dart';
import 'package:jcn_delivery/src/pages/roles/roles_page.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:jcn_delivery/src/utils/default_firebase_config.dart';

User user = User.fromJson(GetStorage().read('user') ?? {});
//User currentAddress = User.fromJson(GetStorage().read('currentAddress') ?? {});

PushNotificationsProvider pushNotificationsProvider =
    new PushNotificationsProvider();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message ${message.messageId}');
  pushNotificationsProvider.showNotification(message);
}

void main() async {
  await GetStorage.init();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyDvXzxv7MJ_tiWao3AHWmK83pzJmmBnNBM',
          appId: '1:759103813559:android:5b7a6e6a928aec680dda32',
          messagingSenderId: '759103813559',
          projectId: 'deliveryapp-b0979'));

  await FirebaseAppCheck.instance.activate(androidDebugProvider: true);
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
    log(user.roles.toString());
    log(user.id.toString());

    pushNotificationsProvider.onMessageListener();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RUSH',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      initialRoute: user.id != null
          ? user.roles!.length > 1
              ? '/roles'
              : '/client/restaurants'
          : '/login',
      getPages: [
        GetPage(name: '/centralChat', page: () => ChatsPage()),
        GetPage(name: '/messages', page: () => MessagesPage()),
        GetPage(name: '/profile/edit', page: () => ProfileEditPage()),
        GetPage(name: '/chatPage', page: () => ChatMainPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/roles', page: () => RolesPage()),
        GetPage(
            name: '/client/products/list',
            page: () => ClientProductsListPage()),
        GetPage(
            name: '/client/orders/create',
            page: () => ClientOrdersCreatePage()),
        GetPage(
            name: '/client/address/list', page: () => ClientAddressListPage()),
        GetPage(
            name: '/client/address/create',
            page: () => ClientAddressCreatePage()),
        GetPage(
            name: '/client/orders/list', page: () => ClientOrdersListPage()),
        GetPage(name: '/client/orders/map', page: () => ClientOrdersMapPage()),
        GetPage(name: '/client/restaurants', page: () => RestaurantsListPage()),
        GetPage(
            name: '/restaurant/orders/list',
            page: () => RestaurantOrdersListPage()),
        GetPage(
            name: '/restaurant/categories/create',
            page: () => RestaurantCategoriesCreatePage()),
        GetPage(
            name: '/delivery/orders/list',
            page: () => DeliveryOrdersListPage()),
        GetPage(
            name: '/delivery/orders/map', page: () => DeliveryOrdersMapPage()),
      ],
      theme: ThemeData(
          fontFamily: 'MontserratRegular',
          primaryColor: Colors.deepOrange,
          colorScheme: ColorScheme.fromSwatch(accentColor: Colors.deepOrange),
          appBarTheme: AppBarTheme(elevation: 0, color: Colors.black)),
    );
  }
}
