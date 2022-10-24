import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/category.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CategoriesProvider {
  String _url = Environment.API_DELIVERY;
  String _api = '/api/categories';
  late BuildContext context;
  late User sessionUser;

  Future init(BuildContext context, User sessionUser) async {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<List<Category>> getAll(restaurantId) async {
    try {
      Uri url = Uri.http(_url, '$_api/getAll/$restaurantId');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken!
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new GeneralActions().logout(context, sessionUser.id!);
      }
      final data = json.decode(res.body); // CATEGORIAS
      Category category = Category.fromJsonList(data);
      return category.toList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<ResponseApi> create(Category category) async {
    Uri url = Uri.http(_url, '$_api/create');
    String bodyParams = json.encode(category);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser.sessionToken!
    };
    final res = await http.post(url, headers: headers, body: bodyParams);

    if (res.statusCode == 401) {
      Fluttertoast.showToast(msg: 'Sesion expirada');
      new GeneralActions().logout(context, sessionUser.id!);
    }

    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }
}
