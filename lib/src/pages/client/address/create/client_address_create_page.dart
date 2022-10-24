import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/pages/client/address/create/client_address_create_controller.dart';
import 'package:jcn_delivery/src/utils/my_colors.dart';

// ignore: must_be_immutable
class ClientAddressCreatePage extends StatefulWidget {
  String? addressName;
  LatLng? addressLatLng;
  ClientAddressCreatePage({Key? key, this.addressName, this.addressLatLng})
      : super(key: key);

  @override
  _ClientAddressCreatePageState createState() =>
      _ClientAddressCreatePageState();
}

class _ClientAddressCreatePageState extends State<ClientAddressCreatePage> {
  ClientAddressCreateController _con = new ClientAddressCreateController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
      _con.refPointController.text = widget.addressName ?? "";
      _con.addressLatLng = widget.addressLatLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBar(),
        bottomNavigationBar: FadeIn(
            duration: Duration(milliseconds: 500), child: _buttonAccept()),
        body: SingleChildScrollView(
          child: FadeIn(
            duration: Duration(milliseconds: 700),
            child: Column(
              children: [
                _textFieldAddress(),
                _textFieldNeighborhood(),
                _textFieldRefPoint()
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: FadeIn(
        child: Text(
          'Crear dirección',
          style: TextStyle(fontSize: 15, color: Colors.white70),
        ),
      ),
      leading: FadeIn(
        child: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textFieldAddress() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: _con.addressController,
        decoration: InputDecoration(
            hintText: 'Casa, trabajo, etc',
            labelText: 'Nombre para el lugar',
            suffixIcon: Icon(
              Icons.location_on,
              color: MyColors.primaryColor,
            )),
      ),
    );
  }

  Widget _textFieldRefPoint() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.refPointController,
        // onTap: _con.openMap,
        autofocus: false,
        focusNode: AlwaysDisabledFocusNode(),
        decoration: InputDecoration(
            labelText: 'Punto de referencia',
            suffixIcon: Icon(
              Icons.map,
              color: MyColors.primaryColor,
            )),
      ),
    );
  }

  Widget _textFieldNeighborhood() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.neighborhoodController,
        decoration: InputDecoration(
            hintText: '',
            labelText: 'Barrio, sector o ciudadela',
            suffixIcon: Icon(
              Icons.location_city,
              color: MyColors.primaryColor,
            )),
      ),
    );
  }

  Widget _buttonAccept() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 30, horizontal: 50),
      child: ElevatedButton(
        onPressed: _con.createAddress,
        child: Text('CREAR DIRECCION'),
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            // ignore: deprecated_member_use
            primary: MyColors.primaryColor),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
