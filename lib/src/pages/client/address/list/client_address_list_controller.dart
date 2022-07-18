import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/address.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/taxi/request.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/client/address/create/client_address_create_page.dart';
import 'package:jcn_delivery/src/provider/address_provider.dart';
import 'package:jcn_delivery/src/provider/orders_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/provider/taxi_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'dart:async';
import 'package:location/location.dart' as location;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ClientAddressListController {
  late BuildContext context;
  late Function refresh;

  List<Address> address = [];
  List<RequestTaxiModel> requestList = [];
  AddressProvider _addressProvider = new AddressProvider();
  TaxiProvider _taxiProvider = new TaxiProvider();
  User? user;
  Address? currentAdress;
  SharedPref _sharedPref = new SharedPref();
  bool opacity = true;
  Position? _position;
  String? addressName;
  String? addressNickName;
  int radioValue = 0;
  LatLng? addressLatLng;
  bool? isCreated;

  Map<String, dynamic>? dataIsCreated;

  OrdersProvider _ordersProvider = new OrdersProvider();
  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  CameraPosition initialPosition =
      CameraPosition(target: LatLng(-2.9017336, -79.0154108), zoom: 13);
  CameraPosition? floatPosition;
  LatLng? nowAddress;
  Completer<GoogleMapController> _mapController = Completer();
  BitmapDescriptor? homeMarker;
  IO.Socket? socket;
  bool? isSocketConected = false;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    homeMarker = await createMarkerFromAsset('assets/img/home.png');

    _addressProvider.init(context, user!);
    _ordersProvider.init(context, user!);
    _taxiProvider.init(context, user!);

    socket = IO.io(
        'http://${Environment.API_DELIVERY}/orders/allDelivery',
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false
        });
    socket?.connect();
    socket?.onConnect((_) => {isSocketConected = true, refresh()});
    socket?.onDisconnect((data) => {isSocketConected = false, refresh()});
    socket?.on('positionAD/', (data) {
      try {
        addMarker(data['id'], data['lat'], data['lng'], 'Tu restaurante', '',
            homeMarker!, 0);
      } catch (e) {}
    });

    checkGPS();
    refresh();
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(
        '[ { "elementType": "geometry", "stylers": [ { "color": "#f5f5f5" } ] }, { "elementType": "labels.icon", "stylers": [ { "visibility": "off" } ] }, { "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] }, { "elementType": "labels.text.stroke", "stylers": [ { "color": "#f5f5f5" } ] }, { "featureType": "administrative.land_parcel", "elementType": "labels.text.fill", "stylers": [ { "color": "#bdbdbd" } ] }, { "featureType": "poi", "elementType": "geometry", "stylers": [ { "color": "#eeeeee" } ] }, { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "featureType": "poi.park", "elementType": "geometry", "stylers": [ { "color": "#e5e5e5" } ] }, { "featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [ { "color": "#9e9e9e" } ] }, { "featureType": "road", "elementType": "geometry", "stylers": [ { "color": "#ffffff" } ] }, { "featureType": "road.arterial", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "color": "#dadada" } ] }, { "featureType": "road.highway", "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] }, { "featureType": "road.local", "elementType": "labels.text.fill", "stylers": [ { "color": "#9e9e9e" } ] }, { "featureType": "transit.line", "elementType": "geometry", "stylers": [ { "color": "#e5e5e5" } ] }, { "featureType": "transit.station", "elementType": "geometry", "stylers": [ { "color": "#eeeeee" } ] }, { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#c9c9c9" } ] }, { "featureType": "water", "elementType": "labels.text.fill", "stylers": [ { "color": "#9e9e9e" } ] } ]');
    _mapController.complete(controller);
  }

  Future<BitmapDescriptor> createMarkerFromAsset(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor descriptor =
        await BitmapDescriptor.fromAssetImage(configuration, path);
    return descriptor;
  }

  void createOrder(
      String? restaurantId,
      double? distance,
      String? tokenRestaurante,
      bool? tarjeta,
      double? priceA,
      double? priceB) async {
    Address a = Address.fromJson(await _sharedPref.read('address') ?? {});
    List<Product> selectedProducts =
        Product.fromJsonList(await _sharedPref.read('order')).toList;
    User userA = User.fromJson(await _sharedPref.read('user'));
    Order order = new Order(
        delivery: userA,
        client: userA,
        address: a,
        idClient: userA.id,
        idAddress: a.id,
        products: selectedProducts,
        restaurantId: restaurantId,
        distance: distance,
        tarjeta: tarjeta == true ? 'Si' : 'No',
        totalCliente: tarjeta == true ? priceB : priceA);
    ResponseApi responseApi = await _ordersProvider.create(order);
    print(responseApi);
    print('ordenCreada');
    sendNotificationRest(tokenRestaurante!);
    print(order.toJson());
    Fluttertoast.showToast(msg: responseApi.message!);
    Navigator.of(context).pushNamedAndRemoveUntil(
        'client/restaurants', (Route<dynamic> route) => false);
  }

  void taxiRequestCreate(double addressId) async {
    RequestTaxiModel request = new RequestTaxiModel(
        requestStatus: 'Buscando ..',
        idClient: int.parse(user!.id!),
        idAddress: addressId);

    try {
      ResponseApi responseApi = await _taxiProvider.create(request);

      if (responseApi.success!) {
        request.id = responseApi.data;

        Fluttertoast.showToast(msg: responseApi.message!);
        Fluttertoast.showToast(msg: 'Registrando para futuras carreras.. ');
        Fluttertoast.showToast(
            msg: 'Selecciona la dirección en tu lista de ubicaciones',
            toastLength: Toast.LENGTH_LONG);
        //   Navigator.pop(context, true);
      }
    } catch (e) {
      //   _sharedPref.save('address', address);

      Fluttertoast.showToast(msg: 'Guardado');
      //  Navigator.pop(context, true);
      refresh();
    }
  }

  void sendNotificationRest(String tokenDelivery) {
    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'sound': 'default'
    };

    pushNotificationsProvider.sendMessage(
        tokenDelivery, data, 'Enciendan las estufas!', 'Pedido Recibido! :D');
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
    int idNumber = int.parse(markerId);
    Marker marker = Marker(
        anchor: Offset(0.5, 0.5),
        markerId: id,
        rotation: heading,
        onTap: () {
          handleRadioValueChangeMarker(lat, lng);
        },
        icon: iconMarker,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title, snippet: content));

    markers[id] = marker;
  }

  void handleRadioValueChangeMarker(double lat, double lng) async {
    int value = address
        .indexWhere((element) => element.lat == lat && element.lng == lng);
    radioValue = value;

    try {
      _sharedPref.save('address', address[value]);
      nowAddress = LatLng(address[value].lat!, address[value].lng!);
    } catch (e) {}

    // opacity = false;
    // animateCameraToPosition(address[value].lat, address[value].lng);
    //  addMarker('client', address[value].lat!, address[value].lng!, 'Cliente',
    //     '..', homeMarker!, 0);

    if (value != -1) {
      addressNickName = address[value].address;
      //  refresh();
    }
    print('Valor seleccioonado: $radioValue');
  }

  void handleRadioValueChange(int? value) async {
    radioValue = value!;

    _sharedPref.save('address', address[value]);
    nowAddress = LatLng(address[value].lat!, address[value].lng!);
    // opacity = false;
    animateCameraToPosition(address[value].lat, address[value].lng);
    //  addMarker('client', address[value].lat!, address[value].lng!, 'Cliente',
    //     '..', homeMarker!, 0);

    if (value != -1) {
      refresh();
    }
    print('Valor seleccioonado: $radioValue');
  }

  Future<List<Address>> getAddress() async {
    address = await _addressProvider.getByUser(user?.id);
    address.sort((a, b) => a.id!.compareTo(b.id!));

    print('GET ADDRESS DONE');
    Address a = Address.fromJson(await _sharedPref.read('address') ?? {});
    int index = address.indexWhere((ad) => ad.id == a.id);
    try {
      //   nowAddress = LatLng(address[index].lat!, address[index].lng!);
      //    animateCameraToPosition(address[index].lat, address[index].lng);
    } catch (e) {}

    address.forEach((ele) {
      if (!markers.containsValue(ele.lat)) {
        addMarker(ele.id!, ele.lat!, ele.lng!, ele.address!, ele.neighborhood!,
            homeMarker!, 0);
        // refresh();
      }
    });

    //  if (index != -1) {
    //   radioValue = index;
    //   }
    print('SE GUARDO LA DIRECCION: ${a.toJson()}');

    // refresh();

    return address;
  }

  Future<List<RequestTaxiModel>> getRequestTaxi() async {
    requestList = await _taxiProvider.getByUser(user?.id ?? '');
    requestList.sort((a, b) => a.id!.compareTo(b.id!));
    if (requestList.length > 0) {
      requestList.forEach((ele) {
        if (!markers.containsValue(ele.id)) {
          addMarker(ele.id!, ele.addressRequest!.lat!, ele.addressRequest!.lng!,
              "Mi Ubicación", ele.taxiClient!.name!, homeMarker!, 0);
          addMarker(ele.id!, ele.lat!, ele.lng!, "Mi Ubicación",
              ele.taxiClient!.name!, homeMarker!, 0);
          // refresh();
        }
      });
/////////// Logica para conectar socket

    }

    return requestList;
  }

  void goToNewAddress() async {
    var refPoint = await showMaterialModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (context) => ClientAddressCreatePage(
              addressLatLng: addressLatLng,
              addressName: addressName,
            ));

    if (refPoint == true) {
      delayRefresh();
    }

    /*var result = await Navigator.pushNamed(context, 'client/address/create',
        arguments: {
          'addressName': addressName,
          'addressLatLng': addressLatLng
        });

  */
  }

  void delayRefresh() {
    Future.delayed(Duration(seconds: 4), () {
      refresh();
    });
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
      await _determinePosition(); // OBTENER LA POSICION ACTUAL Y TAMBIEN SOLICITAR LOS PERMISOS
      _position = await Geolocator.getLastKnownPosition(); // LAT Y LNG
      animateCameraToPosition(_position?.latitude, _position?.longitude);

      print('cambio en el geolocator');
    } catch (e) {
      print('Error: $e');
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

  Future<Null> setLocationDraggableInfo() async {
    // ignore: unnecessary_null_comparison
    if (initialPosition.target.latitude != null) {
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
        }
      }
    }
  }

  Future<LatLng> getCenter() async {
    final GoogleMapController controller = await _mapController.future;
    LatLngBounds visibleRegion = await controller.getVisibleRegion();
    LatLng centerLatLng = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) /
          2,
    );

    return centerLatLng;
  }
}
