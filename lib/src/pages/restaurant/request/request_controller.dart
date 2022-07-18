import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RequestController {
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

  Set<Polyline> polylines = {};
  List<LatLng> points = [];

  late User user;
  SharedPref _sharedPref = new SharedPref();
  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();

  bool isClose = false;

  IO.Socket? socket;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    deliveryMarker = await createMarkerFromAsset('assets/img/delivery2.png');
    homeMarker = await createMarkerFromAsset('assets/img/home.png');

    socket = IO.io(
        'http://${Environment.API_DELIVERY}/orders/allDelivery',
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false
        });
    socket?.connect();
    socket?.on('positionAD/', (data) {
      addMarker(data['id'], data['lat'], data['lng'], 'Tu restaurante', '',
          deliveryMarker!);
    });

    user = User.fromJson(await _sharedPref.read('user'));
    checkGPS();
  }

  void sendNotification(String tokenDelivery) {
    Map<String, dynamic> data = {'click_action': 'FLUTTER_NOTIFICATION_CLICK'};

    pushNotificationsProvider.sendMessage(
        tokenDelivery,
        data,
        'REPARTIDOR ACERCANDOSE',
        'Tu repartidor esta cerca al lugar de entrega');
  }

  void emitPosition() {
    socket?.emit('positionAD',
        {'lat': _position?.latitude, 'lng': _position?.longitude, 'id': 'r1'});
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
    ImageConfiguration configuration = ImageConfiguration();
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
        '[{"elementType":"geometry","stylers":[{"color":"#f5f5f5"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#f5f5f5"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},{"featureType":"road.arterial","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#dadada"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#e5e5e5"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#eeeeee"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#c9c9c9"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]}]');
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

      //  animateCameraToPosition(_position.latitude, _position.longitude);
      //  addMarker('Restaurante', _position!.latitude, _position!.longitude,
      //     'Tu posicion', '', deliveryMarker!);

      //addMarker('home', order.address.lat!, order.address.lng!,
      //    'Lugar de entrega', '', homeMarker!);

      // LatLng from = new LatLng(_position!.latitude, _position!.longitude);
      //  LatLng to = new LatLng(order.address.lat!, order.address.lng!);

//setPolylines(from, to);

      _positionStream = Geolocator.getPositionStream(
              desiredAccuracy: LocationAccuracy.best, distanceFilter: 1)
          .listen((Position position) {
        _position = position;

        emitPosition();

        addMarker(user.id ?? "", _position!.latitude, _position!.longitude,
            'Tu posicion', '', homeMarker!);

        //   animateCameraToPosition(_position.latitude, _position.longitude);
        //   isCloseToDeliveryPosition();

        refresh();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

/*  void call() {
    launch("tel://${order.client.phone}");
  }*/

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
