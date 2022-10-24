import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:jcn_delivery/src/utils/my_snackbar.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class RegisterController extends GetxController {
  late BuildContext context;
  TextEditingController emailController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  GeneralActions generalActions = Get.put(GeneralActions());

  ImagePicker picker = ImagePicker();

  File? imageFile;
  File? appFile;

  UsersProvider usersProvider = UsersProvider();

  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();

  bool isEnable = true;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
  }

  Future selectImage(ImageSource imageSource) async {
    final XFile? image = await picker.pickImage(source: imageSource);

    if (image != null) {
      imageFile = File(image.path);
      update();
    }
  }

  void showAlertDialog(context) async {
    Widget galleryButton = ElevatedButton(
        onPressed: () {
          Get.back();
          selectImage(ImageSource.gallery);
        },
        child: Text('Galería'));
    Widget cameraButton = ElevatedButton(
        onPressed: () {
          Get.back();
          selectImage(ImageSource.camera);
        },
        child: Text('Cámara'));

    AlertDialog alertDialog = AlertDialog(
      title: Text('Selecciona tu imagen'),
      actions: [galleryButton, cameraButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  void register(BuildContext context) async {
    String email = emailController.text.toLowerCase().trim();
    String name = nameController.text;

    if (email.isEmpty || name.isEmpty) {
      MySnackbar.show(context, 'Debes ingresar todos los campos');
      return;
    }

    ProgressDialog progressDialog = ProgressDialog(context: context);
    progressDialog.show(max: 100, msg: 'Registrando Datos...');

    // isEnable = false;

    User user = new User(
        email: email,
        name: name,
        lastname: '',
        phone: generalActions.userUid.value.phone,
        password: generalActions.userUid.value.password);

    Stream stream = await usersProvider.createWithImagePhone(user, {imageFile});
    stream.listen((res) {
      ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
      progressDialog.close();
      if (responseApi.success == true) {
        log(responseApi.data.toString());
        User user = User.fromJson(responseApi.data);

        Get.snackbar('Perfecto!', 'Iniciaremos tu sesión',
            duration: Duration(seconds: 5), backgroundColor: Colors.white);

        loginPhone(generalActions.userUid.value.password!,
            generalActions.userUid.value.phone!);

        //  Navigator.pop(context);

        //   log('Try to register with image');
      } else if (responseApi.success == false) {
        Get.snackbar('Error', 'Ese correo/número ya se ha registrado',
            backgroundColor: Colors.red, colorText: Colors.white);
        //    isEnable = true;

      }
    });
  }

  void loginPhone(String userUid, String phone) async {
    ResponseApi responseApi = await usersProvider.loginPhone(userUid, phone);
    if (responseApi.success == true) {
      User us = User.fromJson(responseApi.data);
      GetStorage().write('user', us.toJson());
      Get.snackbar('${us.name}', 'Hemos preparado lo mejor para ti',
          backgroundColor: Colors.black, colorText: Colors.white);
      Get.toNamed('/roles');
      dynamic currentUserData = await GetStorage().read('user');
      log(currentUserData.toString());
    } else {
      Get.toNamed('/register');
      //    Get.snackbar('Error', 'No se ha iniciado sesión');
    }
  }
}
