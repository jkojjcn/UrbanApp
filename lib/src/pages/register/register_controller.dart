import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:jcn_delivery/src/utils/my_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class RegisterController {
  late BuildContext context;
  TextEditingController emailController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController lastnameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPassswordController =
      new TextEditingController();

  UsersProvider usersProvider = new UsersProvider();
  PushNotificationsProvider pushNotificationsProvider =
      new PushNotificationsProvider();
  PickedFile? pickedFile;
  File? imageFile;
  Function? refresh;

  ProgressDialog? _progressDialog;

  bool isEnable = true;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    usersProvider.init(context);
    _progressDialog = ProgressDialog(context: context);
  }

  void register() async {
    String email = emailController.text.toLowerCase().trim();
    String name = nameController.text;
    String lastname = lastnameController.text;
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPassswordController.text.trim();

    if (email.isEmpty ||
        name.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      MySnackbar.show(context, 'Debes ingresar todos los campos');
      return;
    }

    if (confirmPassword != password) {
      MySnackbar.show(context, 'Las contraseñas no coinciden');
      return;
    }

    if (password.length < 6) {
      MySnackbar.show(
          context, 'Las contraseña debe tener al menos 6 caracteres');
      return;
    }

    _progressDialog?.show(max: 100, msg: 'Espere un momento...');
    isEnable = false;

    User user = new User(
        image: "",
        email: email,
        name: name,
        lastname: lastname,
        phone: phone,
        password: password);

    Stream stream = await usersProvider.createWithImage(user);
    stream.listen((res) async {
      _progressDialog?.close();

      // ResponseApi responseApi = await usersProvider.create(user);
      ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
      print('RESPUESTA: ${responseApi.toJson()}');

      if (responseApi.success!) {
        MySnackbar.show(context, responseApi.message!);
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushReplacementNamed(context, 'login');
        });

        /*  Future.delayed(Duration(seconds: 2), () {
          usersProvider.login(email, password);
          Future.delayed(Duration(seconds: 2), () {
            if (responseApi.success) {
              User user = User.fromJson(responseApi.data);
              _sharedPref.save('user', user.toJson());

              pushNotificationsProvider.saveToken(user.id);

              print('USUARIO LOGEADO: ${user.toJson()}');
              if (user.roles.length > 1) {
                Navigator.pushNamedAndRemoveUntil(
                    context, 'roles', (route) => false);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                    context, user.roles[0].route, (route) => false);
              }
            } else {
              MySnackbar.show(context, responseApi.message);
            }
          });
        });
           */
      } else {
        isEnable = true;
        MySnackbar.show(context, 'Error: Correo o número ya registrado.');
      }
    });
  }

  Future selectImage(ImageSource imageSource) async {
    // ignore: deprecated_member_use
    pickedFile = await ImagePicker().getImage(source: imageSource);
    if (pickedFile != null) {
      // imageFile = File(pickedFile.path);
    }
    Navigator.pop(context);
    refresh!();
  }

  void showAlertDialog() {
    Widget galleryButton = ElevatedButton(
        onPressed: () {
          selectImage(ImageSource.gallery);
        },
        child: Text('GALERIA'));

    Widget cameraButton = ElevatedButton(
        onPressed: () {
          selectImage(ImageSource.camera);
        },
        child: Text('CAMARA'));

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

  void back() {
    Navigator.pop(context);
  }
}
