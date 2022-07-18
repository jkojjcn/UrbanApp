import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/delivery/orders/detail/delivery_orders_detail_page.dart';
import 'package:jcn_delivery/src/provider/orders_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class DeliveryOrdersListController {
  late BuildContext context;
  SharedPref _sharedPref = new SharedPref();
  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  late Function refresh;
  User? user;

  List<String> status = ['DESPACHADO', 'EN CAMINO', 'ENTREGADO'];
  OrdersProvider _ordersProvider = new OrdersProvider();
  Completer<GoogleMapController> _mapController = Completer();
  BitmapDescriptor? homeMarker;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  double distanciaDelivery = 0.0;

  bool? isUpdated;
  IO.Socket? socket;
  CameraPosition initialPosition =
      CameraPosition(target: LatLng(-2.9017336, -79.0154108), zoom: 12);

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    _ordersProvider.init(context, user!);
    homeMarker = await createMarkerFromAsset('assets/img/home.png');
    refresh();
  }

  void socketConnect(bool value) {
    if (value) {
      socket = IO.io(
          'http://${Environment.API_DELIVERY}/orders/delivery',
          <String, dynamic>{
            'transports': ['websocket'],
            'autoConnect': false
          });
      socket?.connect();
      print('Socket conectaod');
    } else {
      socket?.dispose();
    }
  }

  Future<List<Order>> getOrders(String status) async {
    return await _ordersProvider.getByDeliveryAndStatus(user?.id ?? "", status);
  }

  void openBottomSheet(Order order) async {
    isUpdated = await showMaterialModalBottomSheet(
        context: context,
        builder: (context) => DeliveryOrdersDetailPage(
              order: order,
              totalDelivery: distanciaDelivery,
            ));

    if (isUpdated!) {
      refresh();
    }
  }

  restaurantDistanceDelivery(_distanceRC) {
    if (_distanceRC / 1000 <= 1) {
      distanciaDelivery = 1.49;
    } else if (_distanceRC / 1000 <= 2) {
      distanciaDelivery = 1.49;
    } else if ((_distanceRC / 1000 > 2) && (_distanceRC / 1000 <= 3)) {
      distanciaDelivery = 1.49;
    } else if ((_distanceRC / 1000 > 3) && (_distanceRC / 1000 <= 4)) {
      distanciaDelivery = 1.99;
    } else if ((_distanceRC / 1000 > 4) && (_distanceRC / 1000 <= 5)) {
      distanciaDelivery = 2.49;
    } else if ((_distanceRC / 1000 > 5) && (_distanceRC / 1000 <= 6)) {
      distanciaDelivery = 3.25;
    } else if ((_distanceRC / 1000 > 6) && (_distanceRC / 1000 <= 7)) {
      distanciaDelivery = 3.69;
    } else if ((_distanceRC / 1000 > 7) && (_distanceRC / 1000 <= 8)) {
      distanciaDelivery = 4.10;
    } else if ((_distanceRC / 1000 > 8) && (_distanceRC / 1000 <= 9)) {
      distanciaDelivery = 4.49;
    } else if ((_distanceRC / 1000 > 9) && (_distanceRC / 1000 <= 10)) {
      distanciaDelivery = 4.99;
    } else if ((_distanceRC / 1000 > 10) && (_distanceRC / 1000 <= 11)) {
      distanciaDelivery = 5.25;
    } else if ((_distanceRC / 1000 > 11) && (_distanceRC / 1000 <= 12)) {
      distanciaDelivery = 5.99;
    } else if ((_distanceRC / 1000 > 12 && (_distanceRC / 1000 <= 13))) {
      distanciaDelivery = 6.25;
    } else {
      return Icon(Icons.credit_card);
    }
    return distanciaDelivery;
  }

  void logout() {
    _sharedPref.logout(context, user!.id!);
  }

  void goToCategoryCreate() {
    Navigator.pushNamed(context, 'restaurant/categories/create');
  }

  void goToProductCreate() {
    Navigator.pushNamed(context, 'restaurant/products/create');
  }

  void openDrawer() {
    key.currentState?.openDrawer();
  }

  void goToRoles() {
    Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
  }

  Future<BitmapDescriptor> createMarkerFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor descriptor =
        await BitmapDescriptor.fromAssetImage(configuration, path);
    return descriptor;
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(
        '[{"elementType":"geometry","stylers":[{"color":"#f5f5f5"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#f5f5f5"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},{"featureType":"road.arterial","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#dadada"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#c9c9c9"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]}]');
    _mapController.complete(controller);
  }

  void addMarker(String markerId, double lat, double lng, String title,
      String content, BitmapDescriptor iconMarker) {
    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
        markerId: id,
        icon: iconMarker,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title, snippet: content));

    markers[id] = marker;

    //  refresh();
  }

  void updateOrderAcepted(Order order, String id) async {
    if (order.status == 'DESPACHADO') {
      ResponseApi responseApi =
          await _ordersProvider.updateToOnAceptedDelivery(order, id);
      Fluttertoast.showToast(
          msg: responseApi.message!, toastLength: Toast.LENGTH_LONG);
      if (responseApi.success!) {}
    } else {}
  }

  void updateOrderRefuse(Order order) async {
    if (order.status == 'DESPACHADO') {
      ResponseApi responseApi =
          await _ordersProvider.updateToOnRefuseDelivery(order);
      Fluttertoast.showToast(
          msg: responseApi.message!, toastLength: Toast.LENGTH_LONG);
      if (responseApi.success!) {}
    } else {}
  }
}
