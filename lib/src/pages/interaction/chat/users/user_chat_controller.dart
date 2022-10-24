import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/chat.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/provider/users_provider.dart';

class UserController extends GetxController {
  UsersProvider usersProvider = UsersProvider();
  User myUser = User.fromJson(GetStorage().read('user') ?? {});

  Future<List<User>> getUsers() async {
    return await usersProvider.getUsers();
  }

  void goToChat(User user) {
    Get.toNamed('/messages', arguments: {'user': user.toJson()});
  }
}
