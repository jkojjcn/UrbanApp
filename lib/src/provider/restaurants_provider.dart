import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/product.dart';
import 'package:jcn_delivery/src/models/restaurant.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class RestaurantsProvider {
  String _url = Environment.API_DELIVERY;
  String _api = '/api/restaurants';
  late BuildContext context;
  late User sessionUser;

  Future init(BuildContext context, User sessionUser) async {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<List<Restaurant>> getByCategory(String idCategory) async {
    try {
      Uri url = Uri.http(_url, '$_api/findByCategoryRestaurant/$idCategory');
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
      Restaurant restaurant = Restaurant.fromJsonList(data);
      log("${restaurant.toList}");
      return restaurant.toList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<Restaurant>> getByCategoryAndRestaurantName(
      String idCategory, String productName) async {
    try {
      Uri url = Uri.http(_url,
          '$_api/findByCategoryAndRestaurantName/$idCategory/$productName');
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
      Restaurant restaurant = Restaurant.fromJsonList(data);
      return restaurant.toList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
