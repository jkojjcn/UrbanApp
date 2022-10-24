import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/provider/orders_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/utils/my_snackbar.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:url_launcher/url_launcher.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DeliveryOrdersMapController {
  late BuildContext context;
  late Function refresh;
  Position? _position;
  StreamSubscription? _positionStream;

  String? addressName;
  LatLng? addressLatLng;

  CameraPosition initialPosition =
      CameraPosition(target: LatLng(-2.9017336, -79.0154108), zoom: 13);

  Completer<GoogleMapController> _mapController = Completer();

  BitmapDescriptor? deliveryMarker;
  BitmapDescriptor? homeMarker;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  late Order order;

  // Set<Polyline> polylines = {};
  List<LatLng> points = [];

  OrdersProvider _ordersProvider = new OrdersProvider();
  late User user;

  double? _distanceBetween;

  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();

  bool isClose = false;

  IO.Socket? socket;

  Future init(BuildContext context, Function refresh, Order orderWidget) async {
    this.context = context;
    this.refresh = refresh;
    order = orderWidget;
    deliveryMarker = await createMarkerFromAsset('assets/iconApp/logoMoto.png');
    homeMarker = await createMarkerFromAsset('assets/img/home.png');

    socket = IO.io(
        'http://${Environment.API_DELIVERY}/orders/delivery', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    socket?.connect();

    addMarker('home', order.address.lat!, order.address.lng!,
        'Lugar de entrega', '', homeMarker!);

    user = User.fromJson(GetStorage().read('user'));
    _ordersProvider.init(context, user);
    print('ORDEN: ${order.toJson()}');
    checkGPS();
  }

  void sendNotification(String tokenDelivery) {
    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'title': 'Hola soy ${user.name} de Rush!',
      'body': 'Me ecuentro cerca del lugar de entrega. :D',
      'id_message': 'idMensaje',
      'id_chat': 'idChat',
      'url': 'restaurant'
    };

    pushNotificationsProvider.sendMessage(
        tokenDelivery,
        data,
        'Hola soy ${user.name} de Rush!',
        'Me ecuentro cerca del lugar de entrega. :D');
  }

  void saveLocation() async {
    order.lat = _position!.latitude;
    order.lng = _position!.longitude;
    await _ordersProvider.updateLatLng(order);
  }

  void emitPosition() {
    double transform = 1.6;
    double _speed = _position?.speed ?? 0;
    double _finalSpeed = _speed * transform;
    socket?.emit('position', {
      'id_order': order.id ?? 'Libre',
      'lat': _position?.latitude,
      'lng': _position?.longitude,
      'speed': _finalSpeed,
      'heading': _position?.heading
    });
  }

  void isCloseToDeliveryPosition() {
    _distanceBetween = Geolocator.distanceBetween(_position!.latitude,
        _position!.longitude, order.address.lat!, order.address.lng!);

    if (_distanceBetween! <= 200 && !isClose) {
      sendNotification(order.client.notificationToken!);
      isClose = true;
    }
  }

  void launchWaze() async {
    var url =
        'waze://?ll=${order.address.lat.toString()},${order.address.lng.toString()}';
    var fallbackUrl =
        'https://waze.com/ul?ll=${order.address.lat.toString()},${order.address.lng.toString()}&navigate=yes';
    try {
      bool launched =
          // ignore: deprecated_member_use
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        // ignore: deprecated_member_use
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      // ignore: deprecated_member_use
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }

  void launchGoogleMaps() async {
    var url =
        'google.navigation:q=${order.address.lat.toString()},${order.address.lng.toString()}';
    var fallbackUrl =
        'https://www.google.com/maps/search/?api=1&query=${order.address.lat.toString()},${order.address.lng.toString()}';
    try {
      bool launched =
          // ignore: deprecated_member_use
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        // ignore: deprecated_member_use
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      // ignore: deprecated_member_use
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }

  void updateToDelivered() async {
    if (_distanceBetween! <= 800) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('VALOR A RECAUDAR'),
              content: Container(
                height: 70,
                width: 100,
                child: Center(
                  child: Text(
                    '\$ ${order.totalCliente?.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.orange, fontSize: 30),
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Atras',
                      style: TextStyle(color: Colors.red),
                    )),
                TextButton(
                    onPressed: () async {
                      ResponseApi responseApi =
                          await _ordersProvider.updateToDelivered(order);
                      if (responseApi.success!) {
                        Fluttertoast.showToast(
                            msg: responseApi.message!,
                            toastLength: Toast.LENGTH_LONG);
                        sendNotificationClientTnx(
                            order.client.notificationToken!);
                        Get.offNamedUntil(
                            '/delivery/orders/list', (route) => false);
                      }
                    },
                    child: Text(
                      'ENTREGADO',
                      style: TextStyle(color: Colors.green),
                    )),
              ],
            );
          });
    } else {
      MySnackbar.show(
          context, 'Debes estar mas cerca a la posicion de entrega');
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('Aviso'),
              content:
                  Text('El sistema te detecta lejos del punto de entrega.'),
              actions: [
                TextButton(
                    onPressed: () async {
                      ResponseApi responseApi =
                          await _ordersProvider.updateToDelivered(order);
                      if (responseApi.success!) {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Text('VALOR A RECAUDAR'),
                                content: Container(
                                  height: 70,
                                  width: 100,
                                  child: Center(
                                    child: Text(
                                      '\$ ${order.totalCliente?.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          color: Colors.orange, fontSize: 30),
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Atras',
                                        style: TextStyle(color: Colors.red),
                                      )),
                                  TextButton(
                                      onPressed: () async {
                                        ResponseApi responseApi =
                                            await _ordersProvider
                                                .updateToDelivered(order);
                                        if (responseApi.success!) {
                                          Fluttertoast.showToast(
                                              msg: responseApi.message!,
                                              toastLength: Toast.LENGTH_LONG);
                                          sendNotificationClientTnx(
                                              order.client.notificationToken!);
                                          Get.offNamedUntil(
                                              '/delivery/orders/list',
                                              (route) => false);
                                        }
                                      },
                                      child: Text(
                                        'ENTREGADO',
                                        style: TextStyle(color: Colors.green),
                                      )),
                                ],
                              );
                            });
                      }
                    },
                    child: Text('Entregar de todas formas')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Atras'))
              ],
            );
          });
    }
  }

  void sendNotificationClientTnx(String tokenDelivery) {
    Map<String, dynamic> data = {'click_action': 'FLUTTER_NOTIFICATION_CLICK'};

    pushNotificationsProvider.sendMessage(tokenDelivery, data,
        'Gracias por su compra.', 'Disfrute de su orden! :D');
  }

  void addMarker(
    String markerId,
    double lat,
    double lng,
    String title,
    String content,
    BitmapDescriptor iconMarker,
  ) {
    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
        markerId: id,
        anchor: Offset(0.5, 0.5),
        icon: iconMarker,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title, snippet: content));

    markers[id] = marker;

    refresh();
  }

  void selectRefPoint() {
    Map<String, dynamic> data = {
      'address': addressName,
      'lat': addressLatLng?.latitude,
      'lng': addressLatLng?.longitude,
    };

    Navigator.pop(context, data);
  }

  Future<BitmapDescriptor> createMarkerFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration(size: Size(50, 50));
    BitmapDescriptor descriptor =
        await BitmapDescriptor.fromAssetImage(configuration, path);
    return descriptor;
  }

  Future<Null> setLocationDraggableInfo() async {
    // ignore: unnecessary_null_comparison
    if (initialPosition != null) {
      double lat = initialPosition.target.latitude;
      double lng = initialPosition.target.longitude;

      List<Placemark> address = await placemarkFromCoordinates(lat, lng);

      // ignore: unnecessary_null_comparison
      if (address != null) {
        if (address.length > 0) {
          String direction = address[0].thoroughfare!;
          String street = address[0].subThoroughfare!;
          String city = address[0].locality!;
          String department = address[0].administrativeArea!;
          addressName = '$direction #$street, $city, $department';
          addressLatLng = new LatLng(lat, lng);
          // print('LAT: ${addressLatLng.latitude}');
          // print('LNG: ${addressLatLng.longitude}');

          refresh();
        }
      }
    }
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(
        '[ { "elementType": "geometry", "stylers": [ { "color": "#212121" } ] }, { "elementType": "labels.icon", "stylers": [ { "visibility": "off" } ] }, { "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "elementType": "labels.text.stroke", "stylers": [ { "color": "#212121" } ] }, { "featureType": "administrative", "elementType": "geometry", "stylers": [ { "color": "#757575" } ] }, { "featureType": "administrative.country", "elementType": "labels.text.fill", "stylers": [ { "color": "#9e9e9e" } ] }, { "featureType": "administrative.land_parcel", "stylers": [ { "visibility": "off" } ] }, { "featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [ { "color": "#bdbdbd" } ] }, { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "featureType": "poi.park", "elementType": "geometry", "stylers": [ { "color": "#181818" } ] }, { "featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] }, { "featureType": "poi.park", "elementType": "labels.text.stroke", "stylers": [ { "color": "#1b1b1b" } ] }, { "featureType": "road", "elementType": "geometry.fill", "stylers": [ { "color": "#2c2c2c" } ] }, { "featureType": "road", "elementType": "labels.text.fill", "stylers": [ { "color": "#8a8a8a" } ] }, { "featureType": "road.arterial", "elementType": "geometry", "stylers": [ { "color": "#373737" } ] }, { "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "color": "#3c3c3c" } ] }, { "featureType": "road.highway.controlled_access", "elementType": "geometry", "stylers": [ { "color": "#4e4e4e" } ] }, { "featureType": "road.local", "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] }, { "featureType": "transit", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#000000" } ] }, { "featureType": "water", "elementType": "labels.text.fill", "stylers": [ { "color": "#3d3d3d" } ] } ]');
    _mapController.complete(controller);
  }

  void dispose() {
    _positionStream?.cancel();
    socket?.disconnect();
  }

  void updateLocation() async {
    try {
      await _determinePosition(); // OBTENER LA POSICION ACTUAL Y TAMBIEN SOLICITAR LOS PERMISOS
      _position = await Geolocator.getLastKnownPosition(); // LAT Y LNG
      saveLocation();

      //  animateCameraToPosition(_position.latitude, _position.longitude);
      addMarker('delivery', _position!.latitude, _position!.longitude,
          'Tu posicion', '', deliveryMarker!);

      LatLng from = new LatLng(_position!.latitude, _position!.longitude);
      LatLng to = new LatLng(order.address.lat!, order.address.lng!);

      _positionStream = Geolocator.getPositionStream(
              desiredAccuracy: LocationAccuracy.best, distanceFilter: 1)
          .listen((Position position) {
        _position = position;

        emitPosition();

        addMarker('delivery', _position!.latitude, _position!.longitude,
            'Tu posicion', '', deliveryMarker!);

        //   animateCameraToPosition(_position.latitude, _position.longitude);
        isCloseToDeliveryPosition();

        refresh();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void call() {
    // ignore: deprecated_member_use
    launch("tel://${order.client.phone}");
  }

  void checkGPS() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (isLocationEnabled) {
      updateLocation();
    } else {
      bool locationGPS = await location.Location().requestService();
      if (locationGPS) {
        updateLocation();
      }
    }
  }

  Future animateCameraToPosition(double lat, double lng) async {
    GoogleMapController controller = await _mapController.future;
    // ignore: unnecessary_null_comparison
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 13, bearing: 0)));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
