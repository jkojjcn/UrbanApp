import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/publications.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class PublicationsProvider {
  String _url = Environment.API_DELIVERY;
  String _api = '/api/publications';
  late BuildContext context;
  late User sessionUser;

  Future init(BuildContext context, User sessionUser) async {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<List<Publications>> getAll() async {
    try {
      Uri url = Uri.http(_url, '$_api/getAll');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken!
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new GeneralActions().logout(context, sessionUser.id!);
      }
      if (res.statusCode == 201) {
        final data = json.decode(res.body); // publicaciones

        log('Llegaron bien $data');

        Publications publications = Publications.fromJsonList(data);
        return publications.toList;
      } else {
        log('Error: ${res.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
