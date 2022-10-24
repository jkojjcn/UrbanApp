import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/address.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/client/address/create/client_address_create_page.dart';
import 'package:jcn_delivery/src/provider/address_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'dart:async';
import 'package:location/location.dart' as location;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ClientAddressListController {
  late BuildContext context;
  User user = User.fromJson(GetStorage().read('user') ?? {});

  AddressProvider _addressProvider = new AddressProvider();
  GeneralActions generalActions = Get.put(GeneralActions());

  List<Address> address = [];
  Position? _position;
  String? addressName;
  String? addressNickName;
  int radioValue = -1;
  LatLng? addressLatLng;
  String? locationCityName;
  bool? isLocationAvailable;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<CircleId, Circle> circles = <CircleId, Circle>{};

  LatLng cuenca = LatLng(-2.901992, -79.006063);
  LatLng santaElena = LatLng(-2.226897, -80.899548);

  CameraPosition initialPosition =
      CameraPosition(target: LatLng(-2.9017336, -79.0154108), zoom: 13);
  CameraPosition? floatPosition;

  Completer<GoogleMapController> _mapController = Completer();
  BitmapDescriptor? homeMarker;
  IO.Socket? socket;
  late Function refresh;
  bool? isSocketConected = false;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    homeMarker = await createMarkerFromAsset('assets/img/home.png');

    _addressProvider.init(context, user);

    socket = IO.io(
        'http://${Environment.API_DELIVERY}/orders/allDelivery',
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false
        });
    socket?.connect();
    socket?.onConnect((_) => {isSocketConected = true, refresh()});
    // socket?.disconnect((_) => {isSocketConected = false, refresh()});

    getAddress();

    checkGPS();
    refresh();
  }

  void onMapCreated(GoogleMapController controller) {
    addCircleCity('CUENCA', -2.901992, -79.006063, 'Cuenca', '4 Rios Rush');
    addCircleCity(
        'SANTA ELENA', -2.226897, -80.899548, 'Santa Elena', 'Península');
    controller.setMapStyle(
        '[ { "elementType": "geometry", "stylers": [ { "color": "#212121" } ] }, { "elementType": "labels.icon", "stylers": [ { "visibility": "off" } ] }, { "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "elementType": "labels.text.stroke", "stylers": [ { "color": "#212121" } ] }, { "featureType": "administrative", "elementType": "geometry", "stylers": [ { "color": "#757575" } ] }, { "featureType": "administrative.country", "elementType": "labels.text.fill", "stylers": [ { "color": "#9e9e9e" } ] }, { "featureType": "administrative.land_parcel", "stylers": [ { "visibility": "off" } ] }, { "featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [ { "color": "#bdbdbd" } ] }, { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "featureType": "poi.park", "elementType": "geometry", "stylers": [ { "color": "#181818" } ] }, { "featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] }, { "featureType": "poi.park", "elementType": "labels.text.stroke", "stylers": [ { "color": "#1b1b1b" } ] }, { "featureType": "road", "elementType": "geometry.fill", "stylers": [ { "color": "#2c2c2c" } ] }, { "featureType": "road", "elementType": "labels.text.fill", "stylers": [ { "color": "#8a8a8a" } ] }, { "featureType": "road.arterial", "elementType": "geometry", "stylers": [ { "color": "#373737" } ] }, { "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "color": "#3c3c3c" } ] }, { "featureType": "road.highway.controlled_access", "elementType": "geometry", "stylers": [ { "color": "#4e4e4e" } ] }, { "featureType": "road.local", "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] }, { "featureType": "transit", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#000000" } ] }, { "featureType": "water", "elementType": "labels.text.fill", "stylers": [ { "color": "#3d3d3d" } ] } ]');
    _mapController.complete(controller);
  }

  Future<BitmapDescriptor> createMarkerFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor descriptor =
        await BitmapDescriptor.fromAssetImage(configuration, path);
    return descriptor;
  }

  Future animateCameraToPosition(double? lat, double? lng) async {
    GoogleMapController controller = await _mapController.future;
    // ignore: unnecessary_null_comparison
    if (controller != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat!, lng!), zoom: 18, bearing: 0)));
    }
  }

  void addMarker(String markerId, double lat, double lng, String title,
      String content, BitmapDescriptor iconMarker, double heading) {
    MarkerId id = MarkerId(markerId);
    Marker marker = Marker(
        anchor: Offset(0.5, 0.5),
        markerId: id,
        rotation: heading,
        onTap: () {
          handleRadioValueChangeMarker(markerId);
        },
        icon: iconMarker,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title, snippet: content));

    markers[id] = marker;
  }

  void addCircleCity(
      String circleId, double lat, double lng, String title, String content) {
    CircleId id = CircleId(circleId);
    Circle circle = Circle(
      center: LatLng(lat, lng),
      circleId: id,
      strokeWidth: 2,
      radius: 15000,
      //  fillColor: Color.fromARGB(255, 116, 116, 116).withOpacity(0.4),
      strokeColor: Color.fromARGB(255, 255, 123, 0).withOpacity(0.4),
    );

    circles[id] = circle;
  }

  void addCircle(
      String circleId, double lat, double lng, String title, String content) {
    CircleId id = CircleId(circleId);
    Circle circle = Circle(
      center: LatLng(lat, lng),
      circleId: id,
      strokeWidth: 2,
      radius: 7,
      fillColor: Color.fromARGB(255, 116, 116, 116).withOpacity(0.4),
      strokeColor: Color.fromARGB(255, 207, 207, 207).withOpacity(0.4),
      onTap: () {
        handleRadioValueChangeMarker(circleId);
      },
    );
    circles[id] = circle;
  }

  void checkIfPosition(LatLng position) {
    double isNearCuenca = Geolocator.distanceBetween(position.latitude,
        position.longitude, cuenca.latitude, cuenca.longitude);
    double isNearSantaElena = Geolocator.distanceBetween(position.latitude,
        position.longitude, santaElena.latitude, santaElena.longitude);
    if (isNearCuenca < 15000) {
      isLocationAvailable = true;
      locationCityName = 'Cuenca';
    } else if (isNearSantaElena < 15000) {
      isLocationAvailable = true;
      locationCityName = 'Santa Elena';
    } else {
      isLocationAvailable = false;
      locationCityName = 'No disponemos de motorizados en ese sector!';
    }
    address.forEach((element) {
      double isNearOfLocation = Geolocator.distanceBetween(
          position.latitude, position.longitude, element.lat!, element.lng!);
      element.distanceBetwen = isNearOfLocation;
    });
    address.sort((a, b) => a.distanceBetwen!.compareTo(b.distanceBetwen!));
    if (address[0].distanceBetwen! <= 10) {
      radioValue = 0;
      try {
        GetStorage().write('currentAddress', jsonEncode(address.first));
      } catch (e) {}
      try {
        ReadWriteValue('currentAddress', jsonEncode(address.first));
      } catch (err) {}
      refresh();
    } else {
      radioValue = -1;
    }
  }

  void handleRadioValueChangeMarker(String? id) async {
    int value = address.indexWhere((element) => element.id == id);
    radioValue = value;
    Address temporalAddress = GetStorage().read('currentAddress');
    animateCameraToPosition(temporalAddress.lat, temporalAddress.lng);
    if (value != -1) {
      addressNickName = address[value].address;
    }
  }

  Future<List<Address>> getAddress() async {
    address = await _addressProvider.getByUser(user.id);
    try {
      Address a = Address.fromJson(GetStorage().read('currentAddress') ?? {});
      radioValue = address.indexWhere((element) => element.id == a.id);
    } catch (e) {}

    address.forEach((ele) {
      if (!markers.containsValue(ele.id)) {
        addMarker(ele.id!, ele.lat!, ele.lng!, ele.address!, ele.neighborhood!,
            homeMarker!, 0);
      }
      if (!circles.containsValue(ele.id)) {
        addCircle(
          ele.id!,
          ele.lat!,
          ele.lng!,
          ele.address!,
          ele.neighborhood!,
        );
      }
    });
    return address;
  }

  void goToNewAddress() async {
    await showMaterialModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context) => ClientAddressCreatePage(
              addressLatLng: addressLatLng,
              addressName: addressName,
            ));
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

  void updateLocation() async {
    try {
      await _determinePosition();
      _position = await Geolocator.getLastKnownPosition(); // LAT Y LNG
      animateCameraToPosition(_position?.latitude, _position?.longitude);
    } catch (e) {}
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

  Future<Null> setLocationDraggableInfo() async {
    double lat = initialPosition.target.latitude;
    double lng = initialPosition.target.longitude;

    List<Placemark> address = await placemarkFromCoordinates(lat, lng);

    if (address.length > 0) {
      String direction = address[0].thoroughfare!;
      String street = address[0].subThoroughfare!;
      String city = address[0].locality!;
      String department = address[0].administrativeArea!;
      addressName = '$direction #$street, $city, $department';
      addressLatLng = new LatLng(lat, lng);
    }
  }
}
