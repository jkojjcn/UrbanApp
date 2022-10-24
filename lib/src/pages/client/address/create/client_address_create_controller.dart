import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jcn_delivery/src/models/address.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/provider/address_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClientAddressCreateController {
  late BuildContext context;
  late Function refresh;

  TextEditingController refPointController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController neighborhoodController = new TextEditingController();

  LatLng? addressLatLng;

  AddressProvider _addressProvider = new AddressProvider();

  User? user;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(GetStorage().read('user'));
    _addressProvider.init(context, user!);
  }

  void createAddress() async {
    String addressName = addressController.text;
    String neighborhood = neighborhoodController.text;
    double lat = addressLatLng?.latitude ?? 0;
    double lng = addressLatLng?.longitude ?? 0;
    if (addressName.isEmpty || neighborhood.isEmpty) {
      Get.snackbar(
          'Completa los campos', 'Para que nuestro equipo no ande perdido!',
          backgroundColor: Colors.red, colorText: Colors.white);

      return;
    }
    Address address = new Address(
        address: addressName,
        neighborhood: neighborhood,
        lat: lat,
        lng: lng,
        idUser: user?.id!);
    try {
      ResponseApi responseApi = await _addressProvider.create(address);

      if (responseApi.success!) {
        address.id = responseApi.data;
        Get.snackbar('Perfecto!',
            'Selecciona la ubicación en el mapa y presiona el botón Aquí',
            colorText: Colors.white);
        Get.offNamed('/client/address/list');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error');
      Get.offNamed('/client/address/list');
    }
    refresh();
  }
}
