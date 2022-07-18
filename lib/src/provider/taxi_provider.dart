import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/taxi/request.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class TaxiProvider {
  String _url = Environment.API_DELIVERY;
  String _api = '/api/taxi';
  late BuildContext context;
  late User sessionUser;

  Future init(BuildContext context, User sessionUser) async {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<List<RequestTaxiModel>> getByUser(String? idUser) async {
    int idUserInt = int.parse(idUser ?? '');
    try {
      // ignore: unnecessary_brace_in_string_interps
      Uri url = Uri.http(_url, '$_api/findByUser/${idUserInt}');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken!
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new SharedPref().logout(context, sessionUser.id!);
      }
      final data = json.decode(res.body); // CATEGORIAS
      RequestTaxiModel request = RequestTaxiModel.fromJsonList(data);
      return request.toList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<ResponseApi> create(RequestTaxiModel address) async {
    Uri url = Uri.http(_url, '$_api/create');
    String bodyParams = json.encode(address);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser.sessionToken!
    };
    final res = await http.post(url, headers: headers, body: bodyParams);

    if (res.statusCode == 401) {
      Fluttertoast.showToast(msg: 'Sesion expirada');
      new SharedPref().logout(context, sessionUser.id!);
    }

    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }

  Future<List<RequestTaxiModel>> getAllRequest(String? idUser) async {
    int idUserInt = 1;
    try {
      // ignore: unnecessary_brace_in_string_interps
      Uri url = Uri.http(_url, '$_api/getAllRequest/${idUserInt}');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken!
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new SharedPref().logout(context, sessionUser.id!);
      }
      final data = json.decode(res.body); // CATEGORIAS

      RequestTaxiModel request = RequestTaxiModel.fromJsonList(data);
      return request.toList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<ResponseApi> ticketRequest(
      RequestTaxiModel request, String idUser) async {
    request.idTaxi = int.parse(idUser);

    Uri url = Uri.http(_url, '$_api/ticketRequest');
    String bodyParams = json.encode(request);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser.sessionToken!
    };
    final res = await http.put(url, headers: headers, body: bodyParams);

    if (res.statusCode == 401) {
      Fluttertoast.showToast(msg: 'Sesion expirada');
      new SharedPref().logout(context, sessionUser.id!);
    }

    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }
}
