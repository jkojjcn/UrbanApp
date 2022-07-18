import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/delivery/rest_request/request_controller.dart';

// ignore: must_be_immutable
class RestRequestPage extends StatefulWidget {
  User? userDelivery;

  RestRequestPage({Key? key, this.userDelivery}) : super(key: key);

  @override
  State<RestRequestPage> createState() => _RestRequestPageState();
}

class _RestRequestPageState extends State<RestRequestPage> {
  RestRequestController _con = new RestRequestController();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(
        context,
        refresh,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userDelivery?.name ?? ""),
      ),
      body: _googleMaps(),
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

  refresh() {
    if (mounted) setState(() {});
  }
}
