import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';

class ProfileController extends GetxController {
  var user = User.fromJson(GetStorage().read('user')).obs;

  void goToProfileEdit() {
    Get.toNamed('/profile/edit');
  }
}
