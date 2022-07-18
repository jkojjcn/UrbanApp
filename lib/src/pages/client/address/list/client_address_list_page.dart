import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/models/address.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/pages/client/address/create/client_address_create_page.dart';
import 'package:jcn_delivery/src/pages/client/address/list/client_address_list_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:jcn_delivery/src/widgets/no_data_widget.dart';
import 'package:phlox_animations/phlox_animations.dart';

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
    _setStateFuture();
  }

  _setStateFuture() {
    Future.delayed(Duration(seconds: 4), () {
      setState(() {
        loadingState = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = '<platform-view-type>';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    return Scaffold(
      //   backgroundColor: C,

      body: Stack(
        children: [
          Container(
            child: Listener(
              onPointerDown: (event) {
                _isCameraMoving = 0.3;
                setState(() {});
              },
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _con.initialPosition,
                onMapCreated: _con.onMapCreated,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                onCameraMove: (position) {
                  if (_con.requestList.length < 1) {
                    _con.floatPosition = position;
                  }
                },
                markers: Set<Marker>.of(_con.markers.values),
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                onCameraIdle: () {
                  if (_con.requestList.length < 1) {
                    _con.initialPosition =
                        _con.floatPosition ?? _con.initialPosition;
                    _con.setLocationDraggableInfo().then((value) {
                      setState(() {});
                    });
                    _con.handleRadioValueChangeMarker(
                        _con.floatPosition?.target.latitude ?? 0,
                        _con.floatPosition?.target.longitude ?? 0);
                    _isCameraMoving = 1;
                    setState(() {});
                  }
                },
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
          loadingState
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(),
          Align(
            alignment: Alignment.topCenter,
            child: FutureBuilder(
              future: _con.getRequestTaxi(),
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? _con.requestList.length > 0
                        ? Column(
                            children: [
                              Text(
                                _con.requestList.first.requestStatus ?? "",
                                style:
                                    TextStyle(fontFamily: 'MontserratSemiBold'),
                              ),
                              LinearProgressIndicator(
                                color: Colors.amber,
                              ),
                            ],
                          )
                        : _noOrder()
                    : Container();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _noOrder() {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: _isCameraMoving,
          duration: Duration(milliseconds: 500),
          child: Stack(
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
                            padding: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                              Colors.white,
                              Colors.white.withOpacity(0)
                            ])),
                            child: Text(
                              'SELECCIONA TU UBICACIÓN',
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
                              height: MediaQuery.of(context).size.height * 0.25,
                              width: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                Colors.white.withOpacity(0.9),
                                Colors.white.withOpacity(0)
                              ])),
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
                  child: _con.radioValue >= 0
                      ? _buttonAccept()
                      : PhloxAnimations(
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
                                if (_con.radioValue < 0) {
                                  _con.goToNewAddress();
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'hora de pedir taxi');
                                }
                              },
                            ),
                          ),
                        )),
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

  Widget _buttonAccept() {
    return Container(
      //  decoration: BoxDecoration(color: Colors.white.withOpacity(0.5)),
      height: MediaQuery.of(context).size.height * 0.15,
      width: MediaQuery.of(context).size.width * 1,
      child: Stack(
        children: [
          PhloxAnimations(
            fromX: -400,
            toX: 0,
            scaleCurve: Curves.easeIn,
            duration: Duration(milliseconds: 600),
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5)),
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width * 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.12,
                width: MediaQuery.of(context).size.height * 0.12,
                child: PhloxAnimations(
                  fromScale: 0,
                  scaleCurve: Curves.elasticInOut,
                  toScale: 1,
                  duration: Duration(seconds: 1),
                  child: FloatingActionButton(
                    heroTag: 'buttonDelivery',
                    onPressed: () {
                      Navigator.pushNamed(context, 'client/restaurants');
                    },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delivery_dining,
                          ),
                          Text('Delivery')
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.12,
                width: MediaQuery.of(context).size.height * 0.12,
                child: PhloxAnimations(
                  duration: Duration(seconds: 1),
                  fromScale: 0,
                  scaleCurve: Curves.elasticInOut,
                  toScale: 1,
                  child: FloatingActionButton(
                    heroTag: 'buttonTaxi',
                    backgroundColor: Colors.amber,
                    onPressed: () async {
                      if (_con.radioValue < 0) {
                        _con.goToNewAddress();
                      } else {
                        _con.taxiRequestCreate(
                            double.parse(_con.address[_con.radioValue].id!));
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_taxi,
                          color: Colors.white,
                        ),
                        Text(
                          'Pedir Taxi',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _listAddress() {
    ScrollController? _controller;
    return FutureBuilder(
        future: _con.getAddress(),
        builder: (context, AsyncSnapshot<List<Address>> snapshot) {
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
                        return _radioSelectorAddress(
                            snapshot.data![index], index);
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

  Widget _radioSelectorAddress(Address address, int index) {
    // _con.animateCameraToPosition(address.lat, address.lng);
    return Container(
      height: 50,
      child: RadioListTile(
        contentPadding: EdgeInsets.all(2),
        value: index,
        groupValue: _con.radioValue,
        onChanged: _con.handleRadioValueChange,
        activeColor: Colors.orange,
        title: Text(
          address.address ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        subtitle: Text(
          address.neighborhood ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
