import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jcn_delivery/src/pages/client/address/map/client_address_map_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClientAddressMapPage extends StatefulWidget {
  const ClientAddressMapPage({Key? key}) : super(key: key);

  @override
  _ClientAddressMapPageState createState() => _ClientAddressMapPageState();
}

class _ClientAddressMapPageState extends State<ClientAddressMapPage> {
  ClientAddressMapController _con = new ClientAddressMapController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Ubica tu dirección en el mapa',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
        leading: FadeIn(
          child: Positioned(
              left: 5,
              top: 30,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                }, //_con.close,
                icon: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              )),
        ),
      ),
      body: Stack(
        children: [
          _googleMaps(),
          Container(
            padding: EdgeInsets.only(bottom: 15),
            alignment: Alignment.center,
            child: _iconMyLocation(),
          ),
          Container(
            margin: EdgeInsets.only(top: 30),
            alignment: Alignment.topCenter,
            child: _cardAddress(),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: _buttonAccept(),
          ),
          Align(
            alignment: Alignment.topRight,
            child: FloatingActionButton(
                backgroundColor: Colors.orange,
                mini: true,
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
                        left: 15,
                        child: Icon(
                          Icons.search,
                          size: 10,
                          color: Colors.black,
                        ))
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget _buttonAccept() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 30, horizontal: 70),
      child: ElevatedButton(
        onPressed: _con.selectRefPoint,
        child: Text('JUSTO AQUI'),
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            primary: MyColors.primaryColor),
      ),
    );
  }

  Widget _cardAddress() {
    return Container(
      child: Card(
        color: Colors.grey[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            _con.addressName ?? '',
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _iconMyLocation() {
    return Image.asset(
      'assets/iconApp/flagv1.png',
      width: 65,
      height: 65,

      // color: Colors.orange.withOpacity(0.5),
    );
  }

  Widget _googleMaps() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      onCameraMove: (position) {
        _con.initialPosition = position;
      },
      onCameraIdle: () async {
        await _con.setLocationDraggableInfo();
      },
    );
  }

  void refresh() {
    setState(() {});
  }
}
