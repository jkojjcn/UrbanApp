import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/rol.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';

class RolesController {
  late BuildContext context;
  late Function refresh;

  List<Rol>? roles;

  User user = User.fromJson(GetStorage().read('user'));

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    // roles!.add(rolFromJson(user.roles![0]));

    // OBTENER EL USUARIO DE SESION

    refresh();
  }

  void goToPage(String route) {
    Get.offNamedUntil(route, (route) => false);
  }
}
