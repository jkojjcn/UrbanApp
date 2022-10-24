import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:jcn_delivery/src/utils/my_snackbar.dart';

class LoginController extends GetxController {
  late BuildContext context;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  TextEditingController codeAuthentication = new TextEditingController();

  GetStorage storage = GetStorage();

  UsersProvider usersProvider = new UsersProvider();
  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();

  Future init(BuildContext context) async {
    this.context = context;
    await usersProvider.init(context);

    User user = User.fromJson(GetStorage().read('user'));

    print('Usuario: ${user.toJson()}');
  }

  void goToRegisterPage() {
    Get.toNamed('/register');
  }

  void login() async {
    String email = emailController.text.toLowerCase().trim();
    String password = passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      ResponseApi responseApi = await usersProvider.login(email, password);
      if (responseApi.success == true) {
        User us = User.fromJson(responseApi.data);
        storage.write('user', us.toJson());
        Get.snackbar('${us.name}', 'Hemos preparado lo mejor para ti',
            backgroundColor: Colors.black, colorText: Colors.white);
        Get.toNamed('/roles');
        dynamic currentUserData = await storage.read('user');
        log(currentUserData.toString());
      } else {
        Get.snackbar('Error', 'No se ha iniciado sesión');
      }
    } else {
      Get.snackbar('Complete lo datos', 'Ingrese su email y contraseña');
    }
  }

  void loginPhone(String userUid, String phone) async {
    ResponseApi responseApi = await usersProvider.loginPhone(userUid, phone);
    if (responseApi.success == true) {
      User us = User.fromJson(responseApi.data);
      storage.write('user', us.toJson());
      Get.snackbar('${us.name}', 'Hemos preparado lo mejor para ti',
          backgroundColor: Colors.black, colorText: Colors.white);
      Get.toNamed('/roles');
    } else {
      Get.toNamed('/register');
      //    Get.snackbar('Error', 'No se ha iniciado sesión');
    }
  }
}
