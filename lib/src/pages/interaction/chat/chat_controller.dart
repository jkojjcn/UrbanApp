import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jcn_delivery/src/api/environment.dart';
import 'package:jcn_delivery/src/models/chat.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/messages/messages_controller.dart';
import 'package:jcn_delivery/src/provider/chats_provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ChatMainController extends GetxController {
  var tabIndex = 0.obs;

  User user = User.fromJson(GetStorage().read('user'));

  ChatProvider chatProvider = Get.put(ChatProvider());

  Socket socket = io('${Environment.API_DELIVERY_NEW}/chat', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false
  });

  ChatMainController() {
    connectAndListen();
    createChat();
  }
  void createChat() async {
    Chat chat = Chat(idUser1: user.id, idUser2: '1');

    ResponseApi responseApi = await chatProvider.create(chat);

    if (responseApi.success == true) {
      //  Get.snackbar('Creado', responseApi.message ?? 'Error en la respuesta');
    }
  }

  void connectAndListen() {
    if (user.id != null) {
      log('Si hay usuario');
      socket.connect();
      socket.onConnect((data) {
        log('Usuario Conectado a Socket');
      });
    } else {
      log('Usuario es nulo');
    }
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}
