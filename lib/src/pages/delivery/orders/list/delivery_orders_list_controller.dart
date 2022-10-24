import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/delivery/orders/detail/delivery_orders_detail_page.dart';
import 'package:jcn_delivery/src/provider/orders_provider.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class DeliveryOrdersListController {
  late BuildContext context;

  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  late Function refresh;
  User? user;

  List<String> status = ['DESPACHADO', 'EN CAMINO', 'ENTREGADO'];
  OrdersProvider _ordersProvider = new OrdersProvider();
  Completer<GoogleMapController> _mapController = Completer();
  BitmapDescriptor? homeMarker;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  GeneralActions generalActions = Get.put(GeneralActions());

  double distanciaDelivery = 0.0;

  bool? isUpdated;
  IO.Socket? socket;
  CameraPosition initialPosition =
      CameraPosition(target: LatLng(-2.9017336, -79.0154108), zoom: 12);

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(GetStorage().read('user'));

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

  void logout() async {
    await GetStorage().remove('user');
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }

  void goToCategoryCreate() {
    Get.to('/restaurant/categories/create');
  }

  void goToProductCreate() {
    Get.to('/restaurant/products/create');
  }

  void openDrawer() {
    key.currentState?.openDrawer();
  }

  void goToRoles() {
    Get.offNamedUntil('/roles', (route) => false);
  }

  Future<BitmapDescriptor> createMarkerFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor descriptor =
        await BitmapDescriptor.fromAssetImage(configuration, path);
    return descriptor;
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(
        '[ { "elementType": "geometry", "stylers": [ { "color": "#212121" } ] }, { "elementType": "labels.icon", "stylers": [ { "visibility": "off" } ] }, { "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "elementType": "labels.text.stroke", "stylers": [ { "color": "#212121" } ] }, { "featureType": "administrative", "elementType": "geometry", "stylers": [ { "color": "#757575" } ] }, { "featureType": "administrative.country", "elementType": "labels.text.fill", "stylers": [ { "color": "#9e9e9e" } ] }, { "featureType": "administrative.land_parcel", "stylers": [ { "visibility": "off" } ] }, { "featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [ { "color": "#bdbdbd" } ] }, { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "featureType": "poi.park", "elementType": "geometry", "stylers": [ { "color": "#181818" } ] }, { "featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] }, { "featureType": "poi.park", "elementType": "labels.text.stroke", "stylers": [ { "color": "#1b1b1b" } ] }, { "featureType": "road", "elementType": "geometry.fill", "stylers": [ { "color": "#2c2c2c" } ] }, { "featureType": "road", "elementType": "labels.text.fill", "stylers": [ { "color": "#8a8a8a" } ] }, { "featureType": "road.arterial", "elementType": "geometry", "stylers": [ { "color": "#373737" } ] }, { "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "color": "#3c3c3c" } ] }, { "featureType": "road.highway.controlled_access", "elementType": "geometry", "stylers": [ { "color": "#4e4e4e" } ] }, { "featureType": "road.local", "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] }, { "featureType": "transit", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#000000" } ] }, { "featureType": "water", "elementType": "labels.text.fill", "stylers": [ { "color": "#3d3d3d" } ] } ]');
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
