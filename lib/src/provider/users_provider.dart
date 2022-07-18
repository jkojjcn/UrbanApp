import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UsersProvider {
  String _url = Environment.API_DELIVERY;
  String _api = '/api/users';
  String _apiMessage = '/api/message';

  late BuildContext context;
  User? sessionUser;

  Future init(BuildContext context, {sessionUser}) async {
    this.context = context;
    this.sessionUser = sessionUser;
  }

// Message

  Future<List<Message>> getMessage(String idUser) async {
    try {
      Uri url = Uri.http(_url, '$_apiMessage/findMessage/$idUser');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser?.sessionToken ?? ""
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Sesion expirada');
        new SharedPref().logout(context, sessionUser?.id ?? "");
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

  Future<User> getById(String id) async {
    Uri url = Uri.http(_url, '$_api/findById/$id');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser!.sessionToken!
    };
    final res = await http.get(url, headers: headers);

    if (res.statusCode == 401) {
      // NO AUTORIZADO
      Fluttertoast.showToast(msg: 'Tu sesion expiro');
      new SharedPref().logout(context, sessionUser!.id!);
    }

    final data = json.decode(res.body);
    User user = User.fromJson(data);
    return user;
  }

  Future<List<User>> getDeliveryMen() async {
    Uri url = Uri.http(_url, '$_api/findDeliveryMen');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser!.sessionToken!
    };
    final res = await http.get(url, headers: headers);

    if (res.statusCode == 401) {
      // NO AUTORIZADO
      Fluttertoast.showToast(msg: 'Tu sesion expiro');
      new SharedPref().logout(context, sessionUser!.id!);
    }

    final data = json.decode(res.body);
    User user = User.fromJsonList(data);
    return user.toList;
  }

  Future<List<String>> getAdminsNotificationTokens() async {
    Uri url = Uri.http(_url, '$_api/getAdminsNotificationTokens');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser!.sessionToken!
    };
    final res = await http.get(url, headers: headers);

    if (res.statusCode == 401) {
      // NO AUTORIZADO
      Fluttertoast.showToast(msg: 'Tu sesion expiro');
      new SharedPref().logout(context, sessionUser!.id!);
    }

    final data = json.decode(res.body);
    final tokens = List<String>.from(data);
    return tokens;
  }

  Future<Stream> createWithImage(User user) async {
    Uri url = Uri.http(_url, '$_api/create');
    final request = http.MultipartRequest('POST', url);

    request.fields['user'] = json.encode(user);
    final response = await request.send(); // ENVIARA LA PETICION
    return response.stream.transform(utf8.decoder);
  }

  Future<Stream> update(User user, File image) async {
    Uri url = Uri.http(_url, '$_api/update');
    final request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = sessionUser!.sessionToken!;

    // ignore: unnecessary_null_comparison
    if (image != null) {
      request.files.add(http.MultipartFile('image',
          http.ByteStream(image.openRead().cast()), await image.length(),
          filename: basename(image.path)));
    }

    request.fields['user'] = json.encode(user);
    final response = await request.send(); // ENVIARA LA PETICION

    if (response.statusCode == 401) {
      Fluttertoast.showToast(msg: 'Tu sesion expiro');
      new SharedPref().logout(context, sessionUser!.id!);
    }

    return response.stream.transform(utf8.decoder);
  }

  Future<ResponseApi> create(User user) async {
    Uri url = Uri.http(_url, '$_api/create');
    String bodyParams = json.encode(user);
    Map<String, String> headers = {'Content-type': 'application/json'};
    final res = await http.post(url, headers: headers, body: bodyParams);
    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }

  Future<ResponseApi> updateNotificationToken(
      String idUser, String token) async {
    Uri url = Uri.http(_url, '$_api/updateNotificationToken');
    String bodyParams =
        json.encode({'id': idUser, 'notification_token': token});
    Map<String, String> headers = {
      'Content-type': 'application/json',
    };
    final res = await http.put(url, headers: headers, body: bodyParams);

    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }

  Future<ResponseApi> logout(String idUser) async {
    Uri url = Uri.http(_url, '$_api/logout');
    String bodyParams = json.encode({'id': idUser});
    Map<String, String> headers = {'Content-type': 'application/json'};
    final res = await http.post(url, headers: headers, body: bodyParams);
    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }

  Future<ResponseApi> login(String email, String password) async {
    Uri url = Uri.http(_url, '$_api/login');
    String bodyParams = json.encode({'email': email, 'password': password});
    Map<String, String> headers = {'Content-type': 'application/json'};
    final res = await http.post(url, headers: headers, body: bodyParams);
    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }
}
