import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/profile/profile_controller.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class ProfileEditController extends GetxController {
  ImagePicker picker = ImagePicker();

  TextEditingController nameController = new TextEditingController();
  TextEditingController lastnameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();

  File? imageFile;

  User user = User.fromJson(GetStorage().read('user') ?? {});
  UsersProvider usersProvider = UsersProvider();
  ProfileController profileController = Get.find();

  ProfileEditController() {
    nameController.text = user.name!;
    phoneController.text = user.phone!;
    lastnameController.text = user.lastname!;
  }

  void updateUser(BuildContext context) async {
    String name = nameController.text;
    String lastname = lastnameController.text;
    String phone = phoneController.text.trim();
    User u = User(
        id: user.id,
        name: name,
        lastname: lastname,
        phone: phone,
        email: user.email,
        sessionToken: user.sessionToken!,
        image: user.image!);

    ProgressDialog progressDialog = ProgressDialog(context: context);
    progressDialog.show(max: 100, msg: 'Actualizando Datos...');

    if (imageFile == null) {
      ResponseApi responseApi = await usersProvider.update(u);
      progressDialog.close();
      if (responseApi.success == true) {
        log(responseApi.data.toString());

        User userResponse = User.fromJson(responseApi.data);

        profileController.user.value = userResponse;

        Get.snackbar('Se actualizó correctamente!', '${u.name}',
            duration: Duration(seconds: 5), backgroundColor: Colors.white);
        GetStorage().write('user', responseApi.data);
        // Get.offNamed('/login');
        Navigator.pop(context);
      } else if (responseApi.success == false) {
        Get.snackbar('Error', 'No se pudo actualizar, intentelo más tarde',
            backgroundColor: Colors.red, colorText: Colors.white);
        //    isEnable = true;

      }
    } else {
      Stream stream = await usersProvider.updateWithImage(u, imageFile!);
      stream.listen((res) {
        ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
        progressDialog.close();
        if (responseApi.success == true) {
          log(responseApi.data.toString());
          User userResponse = User.fromJson(responseApi.data);
          profileController.user.value = userResponse;
          Get.snackbar('Se actualizó correctamente!', '${userResponse.name}',
              duration: Duration(seconds: 5), backgroundColor: Colors.white);
          GetStorage().write('user', responseApi.data);
          // Get.offNamed('/login');
          Navigator.pop(context);
        } else if (responseApi.success == false) {
          Get.snackbar('Error', 'No se pudo actualizar, intentelo más tarde',
              backgroundColor: Colors.red, colorText: Colors.white);
          //    isEnable = true;

        }
      });
    }
  }

  Future selectImage(ImageSource imageSource) async {
    final XFile? image = await picker.pickImage(source: imageSource);

    if (image != null) {
      imageFile = File(image.path);
      update();
    }
  }

  void showAlertDialog(context) {
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
}
