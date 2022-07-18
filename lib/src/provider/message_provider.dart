import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class MessageProvider {
  String _url = Environment.API_DELIVERY;
  String _api = '/api/message';
  late BuildContext context;
  late User sessionUser;

  Future init(BuildContext context, User sessionUser) async {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<List<Message>> getMessage(String idUser) async {
    try {
      Uri url = Uri.http(_url, '$_api/findMessage/$idUser');
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
      Message message = Message.fromJsonList(data);
      // product.toList.sort((a, b) => a.lat.compareTo(b.price));
      // print(product.toJson());
      return message.toList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<ResponseApi> createNotification(Message message) async {
    Uri url = Uri.http(_url, '$_api/createNotification/$message');
    String bodyParams = json.encode(message);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser.sessionToken!
    };
    final res = await http.put(url, headers: headers, body: bodyParams);

    if (res.statusCode == 401) {
      Fluttertoast.showToast(msg: 'Sesion expirada');
      new SharedPref().logout(context, sessionUser.id ?? "");
    }

    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);

    return responseApi;
  }
}
