import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/models/address.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/taxi/location.dart';
import 'package:jcn_delivery/src/models/taxi/request.dart';
import 'package:jcn_delivery/src/pages/taxi/taxi_controller.dart';
import 'package:jcn_delivery/src/provider/location_stream_provider.dart';
import 'package:phlox_animations/phlox_animations.dart';
import 'package:provider/provider.dart';
import 'package:slide_countdown/slide_countdown.dart';

class TaxiDriverPage extends StatefulWidget {
  TaxiDriverPage({Key? key}) : super(key: key);

  @override
  _TaxiDriverPageState createState() => _TaxiDriverPageState();
}

class _TaxiDriverPageState extends State<TaxiDriverPage>
    with SingleTickerProviderStateMixin {
  TaxiDriverController _con = new TaxiDriverController();
  LocationService locationService = new LocationService();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
      //   BackgroundLocation.startLocationService();

      locationService.locationStream.listen((event) {
        _con.socket?.emit('positionAD', {
          'id': _con.user!.id!,
          'lat': event.latitude,
          'lng': event.longitude,
          'speed': event.speed,
          'heading': event.heading
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Center(
            child: GestureDetector(
              child: Container(
                color: Colors.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    !_con.isSocketConected!
                        ? IconButton(
                            onPressed: refresh, icon: Icon(Icons.refresh))
                        : Container(),
                    Center(
                        child: Text(_con.isSocketConected!
                            ? _con.isLocationEmit
                                ? 'CONECTADO'
                                : 'CONECTARME'
                            : 'SIN CONEXIÓN')),
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: _con.isSocketConected! ? Colors.black : Colors.red,
        ),
        //   backgroundColor: C,

        body: Stack(
          children: [
            Container(
              child: Listener(
                onPointerDown: (event) {},
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _con.initialPosition,
                  onMapCreated: _con.onMapCreated,
                  polylines: _con.polylines,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  markers: Set<Marker>.of(_con.markers.values),
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
            ),
            _con.isSocketConected!
                ? SafeArea(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.green),
                          //   color: Colors.green,
                        ),
                      ),
                    ),
                  )
                : SafeArea(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.red),
                          //   color: Colors.green,
                        ),
                      ),
                    ),
                  ),
            Align(
              alignment: Alignment.topCenter,
              child: FutureBuilder(
                future: _con.getRequestTaxi(),
                builder: (context, snapshot) {
                  if (_con.requestList.length > 0) {
                    if (!_con.markers
                        .containsValue(_con.requestList.last.id)) {}
                  }
                  return snapshot.hasData
                      ? _con.requestList.length > 0
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child:
                                  _radioSelectorAddress(_con.requestList.last))
                          : _noOrder()
                      : Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noOrder() {
    return Stack(
      children: [
        Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          padding: EdgeInsets.only(top: 10, left: 15),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                            Colors.white,
                            Colors.white.withOpacity(0)
                          ])),
                          child: Text(
                            'VIAJES DISPONIBLES',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontFamily: 'MontserratSemiBold'),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height * 0.20,
                            width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3)),
                            child: FadeIn(
                                duration: Duration(milliseconds: 700),
                                child: _listAddress())),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: FloatingActionButton(
                    heroTag: 'ActualPosition',
                    backgroundColor: Colors.amber,
                    mini: false,
                    onPressed: () {
                      _con.updateLocation();
                    },
                    child: Stack(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 25,
                        ),
                        Positioned(
                            left: 10,
                            child: Icon(
                              Icons.search,
                              size: 15,
                              color: Colors.black,
                            ))
                      ],
                    )),
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: PhloxAnimations(
                  fromScale: 0,
                  scaleCurve: Curves.elasticInOut,
                  toScale: 1,
                  duration: Duration(seconds: 1),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: FloatingActionButton.extended(
                      elevation: 8,
                      autofocus: true,
                      label: Text('Registrar ubicación'),
                      heroTag: 'buttonRegister',
                      onPressed: () async {
                        _con.getCurrentLocation();
                        /*_con.socket?.emit('positionAD', {
                          'id_order': 'Libre',
                          'lat': 1.1,
                          'lng': 1.2,
                          'speed': 1,
                          'heading': 1
                        });*/
                        print("Emitio un objeto");
                        //   await _con.getCurrentLocation();
                      },
                    ),
                  ),
                )),
          ],
        ),
        _con.opacity
            ? IgnorePointer(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    height: 100,
                    width: 100,
                    child: Image.asset(
                      'assets/iconApp/pawaflag.png',
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget _listAddress() {
    ScrollController? _controller;
    return FutureBuilder(
        future: _con.getAllRequest(),
        builder: (context, AsyncSnapshot<List<RequestTaxiModel>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data?.length != 0) {
              return FadeIn(
                duration: Duration(seconds: 1),
                child: Scrollbar(
                  trackVisibility: true,
                  //  thumbVisibility: true,
                  child: ListView.builder(
                      controller: _controller,
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (_, index) {
                        return _radioSelectorAddress(snapshot.data![index]);
                      }),
                ),
              );
            } else {
              return FadeIn(duration: Duration(seconds: 1), child: Container());
            }
          } else {
            return Container();
            // FadeIn(duration: Duration(seconds: 3), child: _noAddress()

          }
        });
  }

  Widget _radioSelectorAddress(
    RequestTaxiModel request,
  ) {
    // _con.animateCameraToPosition(address.lat, address.lng);
    double _distanceBetwenClient = 0.0;

    try {
      _distanceBetwenClient = Geolocator.distanceBetween(
              request.addressRequest!.lat!,
              request.addressRequest!.lng!,
              _con.currentLatLng!.latitude,
              _con.currentLatLng!.longitude) /
          1000;
    } catch (e) {
      print(e);
    }

    if (request.requestStatus == 'Buscando ..') {
      return Container(
        height: 80,
        width: 300,
        child: ListTile(
          contentPadding: EdgeInsets.all(10),
          onTap: () {
            _con.handleRadioValueChange(LatLng(
                request.addressRequest!.lat!, request.addressRequest!.lng!));
          },
          tileColor: Colors.orange,
          leading: _distanceBetwenClient != null
              ? Container(
                  height: 80,
                  //  color: Colors.red,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text((_distanceBetwenClient.toStringAsFixed(1)) + ' Km '),
                      Icon(Icons.social_distance)
                    ],
                  ))
              : Container(),
          trailing: FloatingActionButton.extended(
              onPressed: () {
                request.idTime = (_distanceBetwenClient * 1000).toDouble();
                _con.ticketRequest(request);
                Fluttertoast.showToast(msg: 'Actualizado segun la app ');
              },
              backgroundColor: Colors.black,
              heroTag: 'clientRide',
              label: Text('Aceptar')),
          title: Text(
            request.taxiUser!.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          subtitle: Text(
            request.createdAt ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
        ),
      );
    } else if (request.requestStatus == 'Aceptado') {
      return Container(
        height: MediaQuery.of(context).size.height * 0.30,
        width: MediaQuery.of(context).size.width * 1,
        color: Colors.transparent,
        // padding: EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.05,
              // width: MediaQuery.of(context).size.width * 1,
              color: Colors.transparent,
              child: Center(
                child: SlideCountdown(
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(25)),
                    duration: Duration(seconds: request.idTime! ~/ 10)),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.15,
              color: Colors.black,
              child: ListTile(
                //  contentPadding: EdgeInsets.only(bottom: 10),
                onTap: () {
                  _con.handleRadioValueChange(LatLng(
                      request.addressRequest!.lat!,
                      request.addressRequest!.lng!));
                },
                tileColor: Colors.orange,
                leading: _distanceBetwenClient != null
                    ? Container(
                        //   height: 80,
                        //  color: Colors.red,
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 18.0),
                            child: Text(
                              (_distanceBetwenClient.toStringAsFixed(1)) +
                                  ' Km ',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Icon(
                            Icons.social_distance,
                            color: Colors.white,
                          )
                        ],
                      ))
                    : Container(),
                trailing: FloatingActionButton.extended(
                    onPressed: () {
                      request.idTime =
                          (_distanceBetwenClient * 1000).toDouble();

                      if (_con.polylines.isEmpty) {
                        _con.setPolylines(
                            LatLng(_con.requestList.last.addressRequest!.lat!,
                                _con.requestList.last.addressRequest!.lng!),
                            _con.currentLatLng!);
                      } else {
                        _con.polylines.clear();
                        _con.points.clear();
                      }
                    },
                    backgroundColor: Colors.white,
                    heroTag: 'clientRide',
                    label: Text(
                      'Ruta',
                      style: TextStyle(color: Colors.black),
                    )),
                title: Text(
                  request.taxiUser!.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                subtitle: Text(
                  request.createdAt ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
            Container(
                height: MediaQuery.of(context).size.height * 0.10,
                width: MediaQuery.of(context).size.width * 1,
                color: Colors.orange,
                child: Row(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.10,
                      width: MediaQuery.of(context).size.width * 0.5,
                      color: Colors.white,
                      child: GestureDetector(
                        onTap: () {
                          !_con.blockNotificationButton
                              ? _con.sendNotificationTaxi(_con.requestList.last
                                  .taxiClient!.notificationToken!)
                              : Fluttertoast.showToast(msg: 'Un momento..');
                          _con.blockNotificationButton = true;
                          _con.unlockNotification();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notification_important_outlined),
                            Text('Notificar')
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.10,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: GestureDetector(
                        onTap: () {
                          //    _con.openCall(
                          //        _con.requestList.last.taxiClient!.phone);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.call), Text('Llamar')],
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ),
      );
    }
    return Text('data');
  }

  void refresh() {
    setState(() {});
  }
}
