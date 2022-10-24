import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jcn_delivery/src/models/chat.dart';
import 'package:jcn_delivery/src/models/message.dart';
import 'package:jcn_delivery/src/models/response_api.dart';
import 'package:jcn_delivery/src/models/user.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/chat_controller.dart';
import 'package:jcn_delivery/src/pages/interaction/chat/chats/chats_controller.dart';
import 'package:jcn_delivery/src/provider/chats_provider.dart';
import 'package:jcn_delivery/src/provider/message_provider.dart';
import 'package:jcn_delivery/src/provider/push_notifications_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class MessagesController extends GetxController {
  TextEditingController messageController = TextEditingController();

  User userChat = User.fromJson(Get.arguments['user']);
  User myUser = User.fromJson(GetStorage().read('user') ?? {});

  String idChat = '';
  ImagePicker picker = ImagePicker();

  var isWriting = false.obs;

  File? imageFile;

  ChatProvider chatProvider = ChatProvider();
  MessageProvider messageProvider = MessageProvider();
  PushNotificationsProvider pushNotificationsProvider =
      PushNotificationsProvider();

  List<Message> messages = <Message>[].obs;

  ChatMainController chatMainController = Get.find();
  ChatsController chatController = Get.put(ChatsController());

  ScrollController scrollController = ScrollController();

  MessagesController() {
    log(userChat.toJson().toString());
    createChat();
  }

  void sendNotifications(String message, String idMensaje, {url = ''}) {
    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'title': '${myUser.name}',
      'body': message,
      'id_message': idMensaje,
      'id_chat': idChat,
      'url': 'global'
    };
    pushNotificationsProvider.sendMessage(
        userChat.notificationToken ?? '', data, '${myUser.name}', message);
  }

  void listenMessage() {
    chatMainController.socket.on('message/$idChat', (data) {
      log('Data Emitida $data');
      getMessage();
    });
  }

  void listenMessageSeen() {
    chatMainController.socket.on('seen/$idChat', (data) {
      getMessage();
    });
  }

  void emitMessage() {
    chatMainController.socket
        .emit('message', {'id_chat': idChat, 'id_user': userChat.id});
  }

  void emitMessageSeen() {
    chatMainController.socket.emit('seen', {'id_chat': idChat});
  }

  void listenWriting() {
    chatMainController.socket.on('writing/$idChat/${userChat.id}', (data) {
      log('Data Emitida $data');

      isWriting.value = true;

      Future.delayed(Duration(milliseconds: 2000), () {
        isWriting.value = false;
      });
    });
  }

  void emitWriting() {
    chatMainController.socket
        .emit('writing', {'id_chat': idChat, 'id_user': myUser.id});
  }

  void getChats() async {
    var result = await chatProvider.getChats();
    chatController.chats.clear();
    chatController.chats.addAll(result);
  }

  void getMessage() async {
    var result = await messageProvider.getMessagesByChat(idChat);
    messages.clear();
    messages.addAll(result);
    messages.sort((b, a) => b.timestamp!.compareTo(a.timestamp!));

    scrollController.jumpTo(scrollController.position.maxScrollExtent);

    messages.forEach((m) async {
      if (m.status != 'VISTO' && m.idReceiver == myUser.id) {
        await messageProvider.updateToSeen(m.id!);
        emitMessageSeen();
      }
    });

    getChats();
  }

  void createChat() async {
    Chat chat = Chat(idUser1: myUser.id, idUser2: userChat.id);

    ResponseApi responseApi = await chatProvider.create(chat);

    if (responseApi.success == true) {
      idChat = responseApi.data;
      getMessage();
      listenMessage();
      listenWriting();
      listenMessageSeen();

      //   Get.snackbar('Creado', responseApi.message ?? 'Error en la respuesta');
    }
  }

  void sendMessage() async {
    String messageText = messageController.text;

    if (messageText.isEmpty) {
      Get.snackbar('Texto Vacio', 'Ingrese el mensaje');
      return;
    }
    if (idChat.isEmpty) {
      Get.snackbar('Error', 'No se pudo enviar el mensaje idChat Null');
      return;
    }

    Message message = Message(
        message: messageText,
        idSender: myUser.id,
        idReceiver: userChat.id,
        status: 'ENVIADO',
        idChat: idChat,
        isImage: false,
        isVideo: false);
    log(message.toString());

    ResponseApi responseApi = await messageProvider.create(message);

    if (responseApi.success == true) {
      messageController.text = '';
      sendNotifications(messageText, responseApi.data as String);
      getMessage();
      emitMessage();
    }
  }

  Future<File?> compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        quality: 80);
    return result;
  }

  Future selectImage(ImageSource imageSource, BuildContext context) async {
    final XFile? image = await picker.pickImage(source: imageSource);

    if (image != null) {
      imageFile = File(image.path);
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath = dir.absolute.path + "temp.jpg";

      ProgressDialog progressDialog = ProgressDialog(context: context);
      progressDialog.show(max: 100, msg: 'Subiendo Imagen...');
      File? compressFile = await compressAndGetFile(imageFile!, targetPath);
      Message message = Message(
          message: 'IMAGEN',
          idSender: myUser.id,
          idReceiver: userChat.id,
          status: 'ENVIADO',
          idChat: idChat,
          isImage: true,
          isVideo: false);
      log(message.toString());
      Stream stream =
          await messageProvider.createWithImage(message, compressFile!);
      stream.listen((res) {
        progressDialog.close();
        ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
        if (responseApi.success == true) {
          sendNotifications('Imagen', responseApi.data['id'] as String,
              url: responseApi.data['url']);
          getMessage();
          emitMessage();
        }
      });
    }
  }

  void showAlertDialog(context) {
    Widget galleryButton = ElevatedButton(
        onPressed: () {
          Get.back();
          selectImage(ImageSource.gallery, context);
        },
        child: Text('Galería'));
    Widget cameraButton = ElevatedButton(
        onPressed: () {
          Get.back();
          selectImage(ImageSource.camera, context);
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

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    //  chatMainController.socket.off('message/$idChat');
    chatMainController.socket.off('seen/$idChat');
    chatMainController.socket.off('writing/$idChat/${userChat.id}');
  }
}
