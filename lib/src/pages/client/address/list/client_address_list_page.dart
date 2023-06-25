import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/address/list/client_address_list_controller.dart';
import 'package:phlox_animations/phlox_animations.dart';
import 'dart:math' as math;

// ignore: must_be_immutable
class ClientAddressListPage extends StatefulWidget {
  Product? restaurant;
  ClientAddressListPage({Key? key, this.restaurant}) : super(key: key);

  @override
  _ClientAddressListPageState createState() => _ClientAddressListPageState();
}

class _ClientAddressListPageState extends State<ClientAddressListPage>
    with SingleTickerProviderStateMixin {
  ClientAddressListController _con = new ClientAddressListController();

  bool loadingState = true;
  double _isCameraMoving = 1;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 40, 40, 40),
        body: Stack(
          children: [map(), textCity(), socketConnected(), _content()],
        ),
      ),
    );
  }

  Align textCity() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.all(30),
        child: FadeInDown(
          child: Text(
            _con.locationCityName ?? 'Buscando.. ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Align socketConnected() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 5,
          width: 5,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _con.isSocketConected! ? Colors.green : Colors.red),
          //   color: Colors.green,
        ),
      ),
    );
  }

  Container map() {
    return Container(
      child: Listener(
        onPointerDown: (event) {
          _isCameraMoving = 0;
          setState(() {});
        },
        child: FadeIn(
          delay: Duration(seconds: 2),
          duration: Duration(seconds: 1),
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _con.initialPosition,
            onMapCreated: _con.onMapCreated,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            circles: Set<Circle>.of(_con.circles.values),
            onCameraMove: (position) {
              _con.floatPosition = position;
            },
            markers: Set<Marker>.of(_con.markers.values),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            onCameraIdle: () {
              _con.initialPosition = _con.floatPosition ?? _con.initialPosition;
              _con.setLocationDraggableInfo().then((value) {
                setState(() {});
              });

              _isCameraMoving = 1;
              _con.checkIfPosition(_con.floatPosition!.target);
            },
          ),
        ),
      ),
    );
  }

  Widget _content() {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: _isCameraMoving,
          duration: Duration(milliseconds: 300),
          child: Stack(
            children: [
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    children: [
                      FadeInRight(
                        duration: Duration(milliseconds: 500),
                        child: FloatingActionButton(
                          heroTag: 'ActualPosition',
                          backgroundColor: Colors.deepOrange.withOpacity(0.3),
                          mini: true,
                          onPressed: () {
                            _con.updateLocation();
                          },
                          child: Icon(
                            Icons.place_outlined,
                            size: 25,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
              _con.isLocationAvailable == true
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: _con.radioValue >= 0
                          ? _buttonAccept()
                          : PhloxAnimations(
                              fromScale: 0,
                              scaleCurve: Curves.elasticInOut,
                              toScale: 1,
                              duration: Duration(milliseconds: 500),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: FloatingActionButton.extended(
                                  elevation: 8,
                                  backgroundColor: Colors.white,
                                  autofocus: true,
                                  label: Text(
                                    'Registrar ubicación',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'MontserratSemiBold'),
                                  ),
                                  heroTag: 'buttonRegister',
                                  onPressed: () async {
                                    if (_con.radioValue < 0) {
                                      _con.goToNewAddress();
                                    } else {
                                      Fluttertoast.showToast(msg: 'Test');
                                    }
                                  },
                                ),
                              ),
                            ))
                  : Container(),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.15),
            child: Card(
              color: Colors.grey[800],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  _con.addressName ?? '',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            width: MediaQuery.of(context).size.height * 0.12,
            child: PhloxAnimations(
              fromScale: 0,
              scaleCurve: Curves.elasticInOut,
              toScale: 1,
              duration: Duration(milliseconds: 500),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.transparent,
                elevation: 0,
                heroTag: 'iconTaxi',
                onPressed: () {
                  showCupertinoDialog(
                      context: context,
                      builder: (_) {
                        return CupertinoAlertDialog(
                          title: Text('Servicio de TAXI'),
                          content: Column(
                            children: [
                              Text(
                                  'Sigue la carrera en tiempo real, comparte tu ubicación, contacta al taxista de tu amigo/a, paga con tu teléfono y mucho más. '),
                              Text(
                                  'PARA TAXISTAS - Cupos disponibles. Mas información: Escribe en tu chat a soporte')
                            ],
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('Perfecto!'),
                              onPressed: () => Get.back(),
                            )
                          ],
                        );
                      });
                },
                label: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.taxi_alert,
                      ),
                      Text(
                        'Próximamente..',
                        style: TextStyle(fontSize: 11),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: IgnorePointer(
              child: BounceInDown(
                  delay: Duration(seconds: 2),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: Colors.deepOrange,
                    size: 40,
                  ))),
        ),
      ],
    );
  }

  Widget _buttonAccept() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      width: MediaQuery.of(context).size.width * 1,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(bottom: 10),
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.height * 0.15,
              child: PhloxAnimations(
                fromScale: 0,
                scaleCurve: Curves.easeInOutCubic,
                toScale: 1,
                duration: Duration(milliseconds: 300),
                child: FloatingActionButton(
                  elevation: 10,
                  backgroundColor: Colors.deepOrange,
                  heroTag: 'buttonDelivery',
                  onPressed: () {
                    Get.offAllNamed('client/restaurants');
                  },
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delivery_dining,
                        ),
                        Text(
                          'Aquí',
                          style: TextStyle(color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    _con.socket?.dispose();
    _con.socket?.destroy();
    super.dispose();
  }
}
