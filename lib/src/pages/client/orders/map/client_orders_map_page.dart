import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/user.dart';

import 'package:jcn_delivery/src/pages/client/orders/map/client_orders_map_controller.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ClientOrdersMapPage extends StatefulWidget {
  Order? order;
  ClientOrdersMapPage({Key? key, this.order}) : super(key: key);

  @override
  _ClientOrdersMapPageState createState() => _ClientOrdersMapPageState();
}

class _ClientOrdersMapPageState extends State<ClientOrdersMapPage> {
  ClientOrdersMapController _con = new ClientOrdersMapController();

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

  String urlRushImage = "https://i.ibb.co/7V3mqx4/logoIOS.png";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Center(
                child: Text(
                    "\$${widget.order?.totalCliente!.toStringAsFixed(2)}")),
          ),
        ],
        title: Text("\Orden #${widget.order?.id}"),
      ),
      body: Stack(
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.67,
              child: _googleMaps()),
          SafeArea(
            child: Column(
              children: [
                //   _buttonCenterPosition(),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      height: 40,
                      width: 70,
                      decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(25)),
                      child: Center(
                          child: Text(
                        "${_con.deliverySpeed.toStringAsFixed(0) + " Km/h"}",
                        style: TextStyle(color: Colors.white),
                      ))),
                ),
                Spacer(),
                _cardOrderInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _userData(User userData) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            //  width: MediaQuery.of(context).size.width * 0.7,
            child: Row(
              children: [
                userData.image != null
                    ? Container(
                        width: 50,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl:
                                  userData.image != null && userData.image != ''
                                      ? userData.image!
                                      : urlRushImage,
                              placeholder: (context, url) => Shimmer(
                                  child: Container(
                                color: Colors.black,
                              )),
                              imageBuilder: (context, image) => Image(
                                image: image,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(width: 5),
                Text('${userData.name}')
              ],
            ),
          ),
          Container(
            child: TextButton(
                onPressed: () {
                  _showContactMethod(userData);
                },
                child: Text('Contactar')),
          )
        ],
      ),
    );
  }

  _showContactMethod(User user) {
    return showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Contacta a ${user.name} '),
            actions: [
              TextButton(
                  onPressed: () {
                    openTelf(user.phone);
                  },
                  child: Text('Llamada')),
              TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: user.phone))
                        .then((value) {
                      //only if ->
                      Fluttertoast.showToast(
                          msg: 'Texto Copiado'); // -> show a notification
                    });
                  },
                  child: Text('Copiar número')),
              TextButton(
                  onPressed: () {
                    _con.createChat(user);
                  },
                  child: Text('Chat'))
            ],
          );
        });
  }

  openTelf(String? number) async {
    var whatsappURlA = "tel://$number";
    var whatappURLI = "tel://$number";
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
      if (await canLaunch(whatsappURlA)) {
        // ignore: deprecated_member_use
        await launch(whatsappURlA);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    }
  }

  Widget _cardOrderInfo() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.33,
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
            _listTileAddress(widget.order?.address.neighborhood ?? "", 'Barrio',
                Icons.my_location),
            _listTileAddress(widget.order?.address.address ?? "", 'Direccion',
                Icons.location_on),
            Divider(
              color: Colors.grey[400],
              endIndent: 30,
              indent: 30,
            ),
            widget.order!.delivery!.name != null &&
                    widget.order!.delivery!.name != ''
                ? _userData(widget.order!.delivery!)
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _clientInfo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            child: widget.order?.delivery?.image != null
                ? FadeInImage(
                    image: NetworkImage(widget.order?.delivery?.image ?? ""),
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(milliseconds: 50),
                    placeholder: AssetImage('assets/img/no-image.png'),
                  )
                : Image.asset('assets/img/no-image.png'),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            margin: EdgeInsets.only(left: 10),
            child: Text(
              '${widget.order?.delivery?.name ?? ''} ${widget.order?.delivery?.lastname ?? ''}',
              style: TextStyle(color: Colors.black, fontSize: 16),
              maxLines: 1,
            ),
          ),
          Spacer(),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.grey[200]),
            child: IconButton(
              onPressed: () {
                openTelf(widget.order?.delivery!.phone ?? "");
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
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      markers: Set<Marker>.of(_con.markers.values),
      // polylines: _con.polylines,
    );
  }

  void refresh() {
    if (!mounted) return;
    setState(() {});
  }
}
