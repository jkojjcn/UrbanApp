import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/address.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:jcn_delivery/src/utils/shared_pref.dart';

class AddressProvider {
  String _url = Environment.API_DELIVERY;
  String _api = '/api/address';
  late BuildContext context;
  late User sessionUser;

  Future init(BuildContext context, User sessionUser) async {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<List<Address>> getByUser(String? idUser) async {
    try {
      // ignore: unnecessary_brace_in_string_interps
      Uri url = Uri.http(_url, '$_api/findByUser/${idUser}');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken!
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        try {
          await GetStorage().remove('user');
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        } catch (e) {
          log(e.toString());
        }
      }
      final data = json.decode(res.body); // CATEGORIAS
      Address address = Address.fromJsonList(data);
      return address.toList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<ResponseApi> create(Address address) async {
    Uri url = Uri.http(_url, '$_api/create');
    String bodyParams = json.encode(address);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser.sessionToken!
    };
    final res = await http.post(url, headers: headers, body: bodyParams);

    if (res.statusCode == 401) {
      Fluttertoast.showToast(msg: 'Sesion expirada');
      try {
        await GetStorage().remove('user');
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      } catch (e) {
        log(e.toString());
      }
    }

    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }
}
