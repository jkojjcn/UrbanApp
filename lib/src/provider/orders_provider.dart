import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/models/order.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class OrdersProvider {
  String _url = Environment.API_DELIVERY;
  String _api = '/api/orders';
  String _api2 = '/api/message';
  late BuildContext context;
  late User sessionUser;

  Future init(BuildContext context, User sessionUser) async {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<List<Order>> getByStatus(String status) async {
    try {
      print('SESION TOKEN: ${sessionUser.sessionToken}');
      Uri url = Uri.http(_url, '$_api/findByStatus/$status');
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
      Order order = Order.fromJsonList(data);

      return order.toList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<Order>> getByDeliveryAndStatus(
      String idDelivery, String status) async {
    try {
      print('SESION TOKEN: ${sessionUser.sessionToken}');
      Uri url =
          Uri.http(_url, '$_api/findByDeliveryAndStatus/$idDelivery/$status');
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
      Order order = Order.fromJsonList(data);
      return order.toList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<Order>> getByClientAndStatus(String status) async {
    try {
      print('SESION TOKEN: ${sessionUser.sessionToken}');
      Uri url = Uri.http(
          _url, '$_api/findByClientAndStatus/${sessionUser.id}/$status');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser.sessionToken!
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new GeneralActions().logout(context, sessionUser.id!);
      }
      final data = jsonDecode(res.body); // ORDERS
      Order order = Order.fromJsonList(data);
      return order.toList;
    } catch (e) {
      //  print('Error: $e');
      //  log(e.toString());
      return [];
    }
  }

  Future<List<Order>> getByRestaurantId(
      String status, String restaurantId) async {
    //idClient = "asd";
    // status = "PAGADO";
    //  String user_id = sessionUser?.name;

    try {
      //  print('SESION TOKEN: ${sessionUser.sessionToken}');

      Uri url =
          Uri.http(_url, '$_api/findByRestaurantId/$restaurantId/$status');
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
      Order order = Order.fromJsonList(data);

      return order.toList;
    } catch (e) {
      print('Error order: $e');
      return [];
    }
  }

  Future<ResponseApi> create(Order order) async {
    log(order.toJson().toString());
    Uri url = Uri.http(_url, '$_api/create');
    String bodyParams = jsonEncode(order.toJson());
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser.sessionToken!
    };
    final res = await http.post(url, headers: headers, body: bodyParams);

    if (res.statusCode == 401) {
      Fluttertoast.showToast(msg: 'Sesion expirada');
      new GeneralActions().logout(context, sessionUser.id!);
    }

    if (res.statusCode != 201) {
      Get.snackbar('No se ha creado', 'Error');
    }

    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }

  Future<ResponseApi> updateToDispatched(Order order, double time) async {
    order.features = time.toString();
    print(time.toString());

    Uri url = Uri.http(_url, '$_api/updateToDispatched');
    String bodyParams = json.encode(order);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser.sessionToken!
    };
    final res = await http.put(url, headers: headers, body: bodyParams);

    if (res.statusCode == 401) {
      Fluttertoast.showToast(msg: 'Sesion expirada');
      new GeneralActions().logout(context, sessionUser.id ?? "");
    }

    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);

    return responseApi;
  }

  Future<ResponseApi> updateToOnTheWay(Order order, double price) async {
    Uri url = Uri.http(_url, '$_api/updateToOnTheWay/$price');
    String bodyParams = json.encode(order);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser.sessionToken!
    };
    final res = await http.put(url, headers: headers, body: bodyParams);

    if (res.statusCode == 401) {
      Fluttertoast.showToast(msg: 'Sesion expirada');
      new GeneralActions().logout(context, sessionUser.id!);
    }

    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }

  /// Logica de aceptacion  o rechazo delivery
  Future<ResponseApi> updateToOnAceptedDelivery(
      // ignore: non_constant_identifier_names
      Order order,
      // ignore: non_constant_identifier_names
      String id_delivery) async {
    order.idDelivery = id_delivery;

    Uri url = Uri.http(_url, '$_api/updateToOnAceptedDelivery');
    String bodyParams = json.encode(order);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser.sessionToken!
    };
    final res = await http.put(url, headers: headers, body: bodyParams);

    if (res.statusCode == 401) {
      Fluttertoast.showToast(msg: 'Sesion expirada');
      new GeneralActions().logout(context, sessionUser.id!);
    }

    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }

  Future<ResponseApi> updateToOnRefuseDelivery(Order order) async {
    Uri url = Uri.http(_url, '$_api/updateToOnRefuseDelivery');
    String bodyParams = json.encode(order);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser.sessionToken!
    };
    final res = await http.put(url, headers: headers, body: bodyParams);

    if (res.statusCode == 401) {
      Fluttertoast.showToast(msg: 'Sesion expirada');
      new GeneralActions().logout(context, sessionUser.id!);
    }

    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }

  Future<ResponseApi> updateToDelivered(Order order) async {
    Uri url = Uri.http(_url, '$_api/updateToDelivered');
    String bodyParams = json.encode(order);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser.sessionToken!
    };
    final res = await http.put(url, headers: headers, body: bodyParams);

    if (res.statusCode == 401) {
      Fluttertoast.showToast(msg: 'Sesion expirada');
      new GeneralActions().logout(context, sessionUser.id!);
    }

    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }

  Future<ResponseApi> updateLatLng(Order order) async {
    Uri url = Uri.http(_url, '$_api/updateLatLng');
    String bodyParams = json.encode(order);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser.sessionToken!
    };
    final res = await http.put(url, headers: headers, body: bodyParams);

    if (res.statusCode == 401) {
      Fluttertoast.showToast(msg: 'Sesion expirada');
      new GeneralActions().logout(context, sessionUser.id!);
    }

    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }
}
