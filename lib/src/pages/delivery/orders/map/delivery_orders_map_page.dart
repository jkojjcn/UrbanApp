import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/pages/delivery/orders/map/delivery_orders_map_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class DeliveryOrdersMapPage extends StatefulWidget {
  Order? order;
  DeliveryOrdersMapPage({Key? key, this.order}) : super(key: key);

  @override
  _DeliveryOrdersMapPageState createState() => _DeliveryOrdersMapPageState();
}

class _DeliveryOrdersMapPageState extends State<DeliveryOrdersMapPage> {
  DeliveryOrdersMapController _con = new DeliveryOrdersMapController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, widget.order!);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _con.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _googleMaps()),
          SafeArea(
            child: Column(
              children: [
                _buttonCenterPosition(),
                Spacer(),
                _cardOrderInfo(),
              ],
            ),
          ),
          Positioned(top: 40, left: 15, child: _iconGoogleMaps()),
          Positioned(top: 85, left: 15, child: _iconWaze())
        ],
      ),
    );
  }

  Widget _cardOrderInfo() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.38,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3))
          ]),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              '${widget.order?.totalCliente?.toStringAsFixed(2)} \$',
              style: TextStyle(fontSize: 25, color: Colors.green),
            ),
            _listTileAddress(widget.order?.address.neighborhood ?? "..",
                'Barrio', Icons.my_location),
            _listTileAddress(widget.order?.address.address ?? "..", 'Direccion',
                Icons.location_on),
            Divider(
              color: Colors.grey[400],
              endIndent: 30,
              indent: 30,
            ),
            _clientInfo(),
            _buttonNext(),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }

  Widget _clientInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            child: FadeInImage(
              image: NetworkImage(widget.order?.client.image ?? ""),
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 50),
              placeholder: AssetImage('assets/img/no-image.png'),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.33,
              margin: EdgeInsets.only(left: 10),
              child: Text(
                '${widget.order?.client.name ?? ''} ${widget.order?.client.lastname ?? ''}',
                style: TextStyle(color: Colors.black, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Spacer(),
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Colors.grey[200]),
              child: TextButton(
                onPressed: () {
                  openwhatsapp(widget.order?.client.phone ?? "");
                },
                child: Text('WhatsApp'),
              )),
          SizedBox(
            width: 15,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.grey[200]),
            child: IconButton(
              onPressed: () {
                openTelf(widget.order?.client.phone ?? "");
              },
              icon: Icon(
                Icons.phone,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }

  openTelf(String number) async {
    var whatsappURlAndroid = "tel://$number";
    var whatappURLIos = "tel://$number";
    if (Platform.isIOS) {
      // for iOS phone only
      // ignore: deprecated_member_use
      if (await canLaunch(whatappURLIos)) {
        // ignore: deprecated_member_use
        await launch(whatappURLIos, forceSafariVC: false);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    } else {
      // ignore: deprecated_member_use
      if (await canLaunch(whatsappURlAndroid)) {
        // ignore: deprecated_member_use
        await launch(whatsappURlAndroid);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    }
  }

  openwhatsapp(String number) async {
    var whatsapp = number;
    var whatsappURlAndroid =
        "whatsapp://send?phone=" + "+593" + number + "&text=hello";
    var whatappURLI = "https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
    if (Platform.isIOS) {
      // for iOS phone only
      // ignore: deprecated_member_use
      if (await canLaunch(whatappURLI)) {
        // ignore: deprecated_member_use
        await launch(whatappURLI, forceSafariVC: false);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    } else {
      // android , web
      // ignore: deprecated_member_use
      if (await canLaunch(whatsappURlAndroid)) {
        // ignore: deprecated_member_use
        await launch(whatsappURlAndroid);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    }
  }

  Widget _iconGoogleMaps() {
    return GestureDetector(
      onTap: _con.launchGoogleMaps,
      child: Image.asset(
        'assets/img/google_maps.png',
        height: 35,
        width: 35,
      ),
    );
  }

  Widget _iconWaze() {
    return GestureDetector(
      onTap: _con.launchWaze,
      child: Image.asset(
        'assets/img/waze.png',
        height: 35,
        width: 35,
      ),
    );
  }

  Widget _listTileAddress(String title, String subtitle, IconData iconData) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 13),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(iconData),
      ),
    );
  }

  Widget _buttonNext() {
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 5),
      child: ElevatedButton(
        onPressed: _con.updateToDelivered,
        style: ElevatedButton.styleFrom(
            primary: MyColors.primaryColor,
            padding: EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  'ENTREGAR PRODUCTO',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 45, top: 4),
                height: 30,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buttonCenterPosition() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          shape: CircleBorder(),
          color: Colors.white,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.location_searching,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleMaps() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      markers: Set<Marker>.of(_con.markers.values),
      polylines: _con.polylines,
    );
  }

  void refresh() {
    if (!mounted) return;
    setState(() {});
  }
}
