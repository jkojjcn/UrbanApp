import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/models/chat.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/chat_controller.dart';
import 'package:jcn_delivery/src/provider/chats_provider.dart';
import 'package:jcn_delivery/src/utils/shared_pref.dart';

class ChatsController extends GetxController {
  ChatProvider chatProvider = ChatProvider();
  ChatMainController chatController = Get.put(ChatMainController());
  GeneralActions generalActions = Get.put(GeneralActions());

  User myUser = User.fromJson(GetStorage().read('user') ?? {});
  List<Chat> chats = <Chat>[].obs;

  ChatsController() {
    getChats();
    listenMessage();
  }

  void getChats() async {
    var result = await chatProvider.getChats();
    chats.clear();
    chats.addAll(result);

    generalActions.chats.clear();

    generalActions.chats.addAll(result);

    generalActions.chats
        .sort(((a, b) => a.unreadMessage!.compareTo(b.unreadMessage!)));
  }

  void listenMessage() {
    chatController.socket.on('message/${myUser.id}', (data) {
      log('Data Emitida $data');
      getChats();
    });
  }

  void goToChat(Chat chat) {
    User user = User();

    if (chat.idUser1 == myUser.id) {
      user.id = chat.idUser2;
      user.name = chat.nameUser2;
      user.lastname = chat.lastnameUser2;
      user.email = chat.emailUser2;
      user.phone = chat.phoneUser2;
      user.image = chat.imageUser2;
      user.notificationToken = chat.notificationTokenUser2;
    } else {
      user.id = chat.idUser1;
      user.name = chat.nameUser1;
      user.lastname = chat.lastnameUser1;
      user.email = chat.emailUser1;
      user.phone = chat.phoneUser1;
      user.image = chat.imageUser1;
      user.notificationToken = chat.notificationTokenUser1;
    }

    Get.toNamed('/messages', arguments: {'user': user.toJson()});
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    chatController.socket.off('message/${myUser.id}');
  }
}
