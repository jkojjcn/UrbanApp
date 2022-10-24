import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UsersProvider extends GetConnect {
  String rutaNew = Environment.API_DELIVERY_NEW + '/api/users';
  String ruta = Environment.API_DELIVERY;

  String _apiMessage = 'api/message';

  User userSession = User.fromJson(GetStorage().read('user') ?? {});

  late BuildContext context;
  User? sessionUser;

  Future<List<User>> getUsers() async {
    Response response = await get('$rutaNew/getAll/${userSession.id}',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': userSession.sessionToken!
        });

    if (response.statusCode == 401) {
      Get.snackbar('Petición denegada',
          'Tu usuario no tiene permitido obtener esta información');
      return [];
    }

    List<User> users = User.fromJsonGetxList(response.body);
    return users;
  }

  Future<Stream> updateWithImage(User user, File image) async {
    Uri url = Uri.http('$ruta', '/api/users/updateWithImage');
    log('$url');
    final request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = userSession.sessionToken!;
    request.files.add(http.MultipartFile(
        'image', http.ByteStream(image.openRead().cast()), await image.length(),
        filename: basename(image.path)));
    request.fields['user'] = json.encode(user);
    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }

  Future<Stream> createWithImage(User user, image) async {
    Uri url = Uri.http('$ruta', '/api/users/create');
    log('$url');
    final request = http.MultipartRequest('POST', url);
    try {
      request.files.add(http.MultipartFile('image',
          http.ByteStream(image.openRead().cast()), await image.length(),
          filename: basename(image.path)));
    } catch (e) {
      log(e.toString());
    }
    request.fields['user'] = json.encode(user);
    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }

  /////////////////////////////////////////////////////////////////////////////////
  ///
  ///
  Future<Stream> createWithImagePhone(User user, image) async {
    Uri url = Uri.http('$ruta', '/api/users/createPhone');
    log('$url');
    final request = http.MultipartRequest('POST', url);
    try {
      request.files.add(http.MultipartFile('image',
          http.ByteStream(image.openRead().cast()), await image.length(),
          filename: basename(image.path)));
    } catch (e) {
      log(e.toString());
    }
    request.fields['user'] = json.encode(user);
    final response = await request.send();
    return response.stream.transform(utf8.decoder);
  }

  Future<ResponseApi> update(User user) async {
    Response response = await put('$rutaNew/update', user.toJson(), headers: {
      'Content-type': 'application/json',
      'Authorization': userSession.sessionToken!
    });

    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar su cuenta, reintente!');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future<ResponseApi> login(String email, String password) async {
    Response response = await post(
        '$rutaNew/login', {'email': email, 'password': password},
        headers: {'Content-type': 'application/json'});

    if (response.body == null) {
      Get.snackbar('Error', 'No se ha podido logear su cuenta, reintente.');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future<ResponseApi> loginPhone(String uidUser, String phone) async {
    Response response = await post(
        '$rutaNew/loginPhone', {'phone': phone, 'password': uidUser},
        headers: {'Content-type': 'application/json'});

    if (response.body == null) {
      Get.snackbar('Error', 'No se ha podido logear su cuenta, reintente.');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  //// Update Notification Token
  Future<ResponseApi> updateNotificationToken(
      String idUser, String token) async {
    Response response = await put('$rutaNew/updateNotificationToken', {
      'id': idUser,
      'notification_token': token
    }, headers: {
      'Content-type': 'application/json',
      'Authorization': userSession.sessionToken!
    });

    if (response.body == null) {
      Get.snackbar('Error', 'No se pudo actualizar su cuenta, reintente!');
      return ResponseApi();
    }
    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }

  Future init(BuildContext context, {sessionUser}) async {
    this.context = context;
    this.sessionUser = sessionUser;
  }

// Message

  Future<User> getById(String id) async {
    Uri url = Uri.http(ruta, '$ruta/findById/$id');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser!.sessionToken!
    };
    final res = await http.get(url, headers: headers);

    if (res.statusCode == 401) {
      // NO AUTORIZADO
      Fluttertoast.showToast(msg: 'Tu sesion expiro');
      new GeneralActions().logout(context, sessionUser!.id!);
    }

    final data = json.decode(res.body);
    User user = User.fromJson(data);
    return user;
  }

  Future<List<User>> getDeliveryMen() async {
    Uri url = Uri.http(ruta, '/api/users/findDeliveryMen');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': sessionUser!.sessionToken!
    };
    final res = await http.get(url, headers: headers);

    if (res.statusCode == 401) {
      // NO AUTORIZADO
      Fluttertoast.showToast(msg: 'Tu sesion expiro');
      new GeneralActions().logout(context, sessionUser!.id!);
    }
    if (res.body.isEmpty) {
      log('El delivery está vacio');
    }

    final data = json.decode(res.body);
    User user = User.fromJsonList(data);
    return user.toList;
  }

  Future<ResponseApi> logout(String idUser) async {
    Uri url = Uri.http('$ruta', '/logout');
    String bodyParams = json.encode({'id': idUser});
    Map<String, String> headers = {'Content-type': 'application/json'};
    final res = await http.post(url, headers: headers, body: bodyParams);
    final data = json.decode(res.body);
    ResponseApi responseApi = ResponseApi.fromJson(data);
    return responseApi;
  }
}
